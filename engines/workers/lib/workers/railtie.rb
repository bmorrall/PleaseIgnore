require 'sidekiq'
require 'workers/background_job'

module Workers
  # Overrides ActiveJob defaults with common ActiveJob overrides
  class Railtie < ::Rails::Railtie
    initializer 'workers.initialize_active_job_queue_adaptor' do
      ActiveJob::Base.queue_adapter =
        if Workers.configuration.sidekiq_enabled?
          :sidekiq # Ensure sidekiq is used for ActiveJob tasks
        else
          :inline # Fallback to running jobs inline
        end
    end

    initializer 'workers.initialize_sidekiq' do
      # :nocov:
      if Workers.configuration.redis_url.present?
        Sidekiq.configure_server do |config|
          config.redis = Workers.sidekiq_config
        end
        Sidekiq.configure_client do |config|
          config.redis = Workers.sidekiq_config
        end
      end
      # :nocov:
    end

    initializer 'workers.monkey_patch_action_mailer_delivery_job' do
      # Add Configuration to ActiveMailer async deliveries
      ActionMailer::DeliveryJob.include Workers::BackgroundJob
    end
  end
end
