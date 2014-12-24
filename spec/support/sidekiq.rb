# Run Sidekiq jobs inline
require 'sidekiq/testing'
Sidekiq::Testing.inline!
Sidekiq.logger = nil # Silence logging messages
