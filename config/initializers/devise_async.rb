require 'settings'

# Send devise emails through ActiveJob
Devise::Async.setup do |config|
  config.enabled = ::Settings.sidekiq_enabled?
  config.backend = :active_job
  config.queue = :mailer
end
