# frozen_string_literal: true

require 'active_support'
require 'active_record'
require 'logger'

require_relative 'verbose_migrations/version'
require_relative 'verbose_migrations/railtie'

module VerboseMigrations
  module MigrationExtension
    cattr_accessor :verbose_logger, default: nil
    cattr_accessor :verbosity,      default: nil

    def verbose? = verbosity.present? && verbose_logger.present?
    def verbose!(logger: ActiveRecord::Base.logger, level: Logger::DEBUG)
      self.verbose_logger = logger
      self.verbosity      = level
    end

    def migrate(...)
      verbosity_was, verbose_logger.level = verbose_logger.level, verbosity if verbose?

      super
    ensure
      verbose_logger.level = verbosity_was if verbose?
    end
  end
end
