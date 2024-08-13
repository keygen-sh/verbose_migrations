# frozen_string_literal: true

require 'verbose_migrations'
require 'active_support'
require 'active_record'
require 'rails'
require 'sqlite3'
require 'logger'

require 'rspec/mocks/standalone'
require 'prism'

ActiveRecord::Base.logger = ActiveSupport::TaggedLogging.new(
  ActiveSupport::Logger.new(STDOUT),
)

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:',
)

RSpec::Matchers.define_negated_matcher :not_change, :change

module TransitionThrough
  ##
  # TransitionExpression walks a Prism AST until we find a transition expression, e.g.:
  #
  #   expect { ... }.to transition { ... }.through [...]
  #
  # Returns the transition state in the transition block.
  class TransitionExpression < Prism::Visitor
    Result = Data.define(:receiver, :method_name)

    attr_reader :at, :result

    def initialize(at:) = @at = at

    def visit_call_node(node)
      case node
      in name: :transition, block: Prism::BlockNode(body: Prism::Node(body: [Prism::CallNode(receiver:, name: method_name)]), location:) if location.start_line == at
        @result = Result.new(receiver:, method_name:)
      else
        super
      end
    end
  end

  class Matcher
    include RSpec::Matchers, RSpec::Matchers::Composable, RSpec::Mocks::ExampleMethods

    attr_reader :state_block

    def initialize(state_block)
      @state_block     = state_block
      @expected_states = []
      @actual_states   = []
    end

    def supports_block_expectations? = true
    def matches?(expect_block)
      path, start_line = state_block.source_location

      # walk the ast until we find our transition expression
      exp = TransitionExpression.new(at: start_line)
      ast = Prism.parse_file(path)

      ast.value.accept(exp)

      # get the actual transitioning object from the state block's binding
      receiver = state_block.binding.eval(exp.result.receiver.name.to_s)

      # get the receivers method names for stubbing
      setter = receiver.method(:"#{exp.result.method_name}=")
      getter = receiver.method(exp.result.method_name)

      # record initial state
      @actual_states = [getter.call]

      # stub the setter so that we can track state transitions
      allow(receiver).to receive(setter.name) do |value|
        @actual_states << value

        setter.call(value)
      end

      # call the expect block
      expect_block.call

      # assert states match
      @actual_states == @expected_states
    end

    def through(*values)
      @expected_states = values.flatten(1)

      self
    end

    def failure_message
      "expected block to transition through #{@expected_states.inspect} but it transitioned through #{@actual_states.inspect}"
    end

    def failure_message_when_negated
      "expected block not to transition through #{@expected_states.inspect} but it did"
    end
  end

  module Methods
    def transition(&block) = Matcher.new(block)
  end
end

RSpec.configure do |config|
  config.include TransitionThrough::Methods

  config.expect_with(:rspec) { _1.syntax = :expect }
  config.disable_monkey_patching!

  config.around :each, :suppress_migration_messages do |example|
    ActiveRecord::Migration.suppress_messages { example.run }
  end
end
