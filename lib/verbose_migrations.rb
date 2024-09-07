# frozen_string_literal: true

require 'active_support'
require 'active_record'
require 'logger'

require_relative 'verbose_migrations/ext'
require_relative 'verbose_migrations/version'
require_relative 'verbose_migrations/railtie'

module VerboseMigrations; end
