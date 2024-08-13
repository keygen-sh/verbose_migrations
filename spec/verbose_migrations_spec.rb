# frozen_string_literal: true

require 'spec_helper'

RSpec.describe VerboseMigrations do
  let(:migration) { Class.new(ActiveRecord::Migration[Rails.version[..2]]) { def up = nil } }
  let(:logger)    { ActiveRecord::Base.logger }

  # FIXME(ezekg) verbosity effects all migrations
  before { migration.verbose_logger, migration.verbosity = nil, nil }
  before { logger.level = Logger::UNKNOWN }

  describe '.verbose!' do
    it 'enables verbose logging' do
      expect { migration.verbose! }.to change { migration.verbose? }.from(false).to(true)
    end

    it 'enables verbose logging at debug level by default' do
      expect { migration.verbose! }.to change { migration.verbosity }.from(nil).to(Logger::DEBUG)
    end

    it 'enables verbose logging at custom :level' do
      expect { migration.verbose!(level: Logger::INFO) }.to(
        change { migration.verbosity }.from(nil).to(Logger::INFO),
      )
    end

    it 'enables verbose logging for custom :logger' do
      verbose_logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))

      expect { migration.verbose!(logger: verbose_logger) }.to(
        change { migration.verbose_logger }.from(nil).to(verbose_logger),
      )
    end
  end

  describe '#migrate', :suppress_migration_messages do
    let(:instance) { migration.new }

    it 'enables verbose logging at debug level by default' do
      migration.verbose!(logger:)

      expect { instance.migrate(:up) }.to(
        transition { logger.level }.through [Logger::UNKNOWN, Logger::DEBUG, Logger::UNKNOWN]
      )
    end

    it 'enables verbose logging at custom :level' do
      migration.verbose!(level: Logger::INFO)

      expect { instance.migrate(:up) }.to(
        transition { logger.level }.through [Logger::UNKNOWN, Logger::INFO, Logger::UNKNOWN]
      )
    end

    it 'enables verbose logging for custom :logger' do
      verbose_logger = ActiveSupport::TaggedLogging.new(Logger.new(nil))
      verbose_logger.level = Logger::UNKNOWN

      migration.verbose!(logger: verbose_logger)

      expect { migration.new.migrate(:up) }.to(
        transition { verbose_logger.level }.through(Logger::UNKNOWN, Logger::DEBUG, Logger::UNKNOWN).and(
          not_change { logger.level },
        ),
      )

      expect(logger.level).to eq Logger::UNKNOWN
    end
  end
end
