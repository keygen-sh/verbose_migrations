# frozen_string_literal: true

require_relative "lib/verbose_migrations/version"

Gem::Specification.new do |spec|
  spec.name        = 'verbose_migrations'
  spec.version     = VerboseMigrations::VERSION
  spec.authors     = ['Zeke Gabrielse']
  spec.email       = ['oss@keygen.sh']
  spec.summary     = 'Set Active Record logger to DEBUG mode during Active Record migrations.'
  spec.description = 'Override Active Record logger to DEBUG mode during Active Record migrations to easily follow along and spot blocking queries in a migration, even when the logger is set to e.g. WARN.'
  spec.homepage    = 'https://github.com/keygen-sh/verbose_migrations'
  spec.license     = 'MIT'

  spec.required_ruby_version = '>= 3.1'
  spec.files                 = %w[LICENSE CHANGELOG.md CONTRIBUTING.md SECURITY.md README.md] + Dir.glob('lib/**/*')
  spec.require_paths         = ['lib']

  spec.add_dependency 'rails', '>= 6.0'

  spec.add_development_dependency 'rspec-rails'
end
