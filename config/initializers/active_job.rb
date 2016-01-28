require 'settings'

if ::Settings.sidekiq_enabled?
  # Ensure sidekiq is used for ActiveJob tasks
  ActiveJob::Base.queue_adapter = :sidekiq
else
  # Fallback to running jobs inline
  ActiveJob::Base.queue_adapter = :inline
end
