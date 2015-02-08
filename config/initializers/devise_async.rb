
# Send devise emails through ActiveJob
Devise::Async.enabled = true
Devise::Async.backend = :active_job
