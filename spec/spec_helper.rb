# frozen_string_literal: true

require 'verbose_migrations'
require 'active_support'
require 'active_record'
require 'rails'
require 'sqlite3'
require 'logger'

ActiveRecord::Base.logger = ActiveSupport::TaggedLogging.new(
  ActiveSupport::Logger.new(STDOUT),
)

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:',
)

RSpec::Matchers.define_negated_matcher :not_change, :change
RSpec::Matchers.define :transition do |receiver, method_name|
  supports_block_expectations

  match do |expectation|
    setter_method = receiver.method(:"#{method_name}=")
    getter_method = receiver.method(method_name)
    initial_state = getter_method.call

    @actual_states = [initial_state]

    allow(receiver).to receive(setter_method.name) do |value|
      @actual_states << value

      setter_method.call(value)
    end

    expectation.call

    @actual_states == @expected_states
  end

  chain :through do |expected_states|
    @expected_states = expected_states
  end

  failure_message do
    "expected block to transition through #{@expected_states} but it transitioned through #{@actual_states}"
  end

  failure_message_when_negated do
    "expected block not to transition through #{@expected_states} but it did"
  end
end

RSpec.configure do |config|
  config.expect_with(:rspec) { _1.syntax = :expect }
  config.disable_monkey_patching!

  config.around :each, :suppress_migration_messages do |example|
    ActiveRecord::Migration.suppress_messages { example.run }
  end
end
