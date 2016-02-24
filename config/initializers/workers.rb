require 'settings'

Workers.configure do |config|
  config.redis_url = ::Settings.redis_url
  config.sidekiq_namespace = 'sidekiq'
end
