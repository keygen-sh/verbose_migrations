# frozen_string_literal: true

module VerboseMigrations
  ActiveSupport.on_load :active_record do
    ActiveRecord::Migration.prepend(MigrationExtension)
  end
end

