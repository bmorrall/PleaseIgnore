require 'settings'

ActiveJob::Base.queue_adapter =
  if ::Settings.sidekiq_enabled?
    :sidekiq # Ensure sidekiq is used for ActiveJob tasks
  else
    :inline # Fallback to running jobs inline
  end
