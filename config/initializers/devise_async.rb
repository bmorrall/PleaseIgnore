# Send devise emails through ActiveJob
Devise::Async.setup do |config|
  config.enabled = true
  config.backend = :active_job
  config.queue = :mailer
end
