# Ensure sidekiq is used for ActiveJob tasks
ActiveJob::Base.queue_adapter = :sidekiq
