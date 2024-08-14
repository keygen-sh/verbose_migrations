# frozen_string_literal: true

require 'transition_through'
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

RSpec.configure do |config|
  config.include TransitionThrough::Methods

  config.expect_with(:rspec) { _1.syntax = :expect }
  config.disable_monkey_patching!

  config.around :each, :suppress_migration_messages do |example|
    ActiveRecord::Migration.suppress_messages { example.run }
  end
end
