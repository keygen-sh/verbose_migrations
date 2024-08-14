# frozen_string_literal: true

require_relative 'lib/verbose_migrations/version'

Gem::Specification.new do |spec|
  spec.name        = 'verbose_migrations'
  spec.version     = VerboseMigrations::VERSION
  spec.authors     = ['Zeke Gabrielse']
  spec.email       = ['oss@keygen.sh']
  spec.summary     = 'Enable verbose logging for Active Record migrations, regardless of configured log level, to monitor query speed and execution.'
  spec.description = 'Enable verbose logging for Active Record migrations, regardless of configured log level. Monitor query speed, query execution, and overall progress when executing long running or otherwise risky migrations.'
  spec.homepage    = 'https://github.com/keygen-sh/verbose_migrations'
  spec.license     = 'MIT'

  spec.required_ruby_version = '>= 3.1'
  spec.files                 = %w[LICENSE CHANGELOG.md CONTRIBUTING.md SECURITY.md README.md] + Dir.glob('lib/**/*')
  spec.require_paths         = ['lib']

  spec.add_dependency 'rails', '>= 6.0'

  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'transition_through', '~> 1.0'
  spec.add_development_dependency 'sqlite3', '~> 1.4'
  spec.add_development_dependency 'prism'
end
