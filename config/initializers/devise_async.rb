# Send devise emails through ActiveJob
Devise::Async.setup do |config|
  config.enabled = true
  config.backend = :active_job
  config.queue = Workers::MAILERS
end

# Add Configuration to Devise Mailer Tasks
Devise::Async::Backend::ActiveJob::Runner.include Workers::BackgroundJob
