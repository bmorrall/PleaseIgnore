require 'workers'

module Users
  # Provides Authenticatable Users model to Rails
  # - sets up Devise::Async
  class Engine < ::Rails::Engine
    engine_name :users

    config.autoload_paths << File.expand_path('../../app', __FILE__)

    initializer 'users.setup_devise_async' do
      # Send devise emails through ActiveJob
      Devise::Async.setup do |config|
        config.enabled = true
        config.backend = :active_job
        config.queue = Workers::MAILERS
      end

      # Add Configuration to Devise Mailer Tasks
      Devise::Async::Backend::ActiveJob::Runner.include Workers::BackgroundJob
    end
  end
end
