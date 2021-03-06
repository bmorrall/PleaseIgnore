require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PleaseIgnore
  # PleaseIgnore is a Rails Application
  class Application < Rails::Application
    CURRENT_COMMIT = `git describe --always --tags`.strip.freeze

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = 'UTC'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.i18n.enforce_available_locales = true

    # Update Generators to use factory girl
    config.generators do |g|
      g.test_framework :rspec, fixture: true
      g.fixture_replacement :factory_girl, dir: 'spec/factories'

      g.decorator false
      g.decorator_specs false
      g.helper false
      g.helper_specs false
      g.view_specs false
    end

    # Fix deprecation errors with transactional callbacks
    config.active_record.raise_in_transactional_callbacks = true

    # Use sidekiq for ActiveJob
    config.active_job.queue_adapter = :sidekiq

    # Allow Turboboost/remote forms to work without Javascript
    config.action_view.embed_authenticity_token_in_remote_forms = true

    # Add response codes for common exceptions
    Rails.application.config.action_dispatch.rescue_responses['CanCan::AccessDenied'] = :forbidden

    # Add Extensions onto the Version Model
    config.after_initialize do
      PaperTrail::Version.include CoreExtensions::PaperTrail::VersionItemOwner
      PaperTrail::Version.include CoreExtensions::PaperTrail::VersionMetaStore
    end

    # Set whodunnint for non-ActionController changes
    rake_tasks do
      # Keep track of rake tasks
      PaperTrail.whodunnit = "#{`whoami`.strip}: rake #{ARGV.join ' '} (#{CURRENT_COMMIT})"
    end
    runner do
      # Keep track of runner tasks
      PaperTrail.whodunnit = "#{`whoami`.strip}: runner (#{CURRENT_COMMIT})"
    end
    console do
      # Keep track of console commands
      PaperTrail.whodunnit = "#{`whoami`.strip}: console (#{CURRENT_COMMIT})"
    end
  end
end
