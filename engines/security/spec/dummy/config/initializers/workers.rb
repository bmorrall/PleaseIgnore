Workers.configure do |config|
  config.redis_url = 'redis://127.0.0.1:6379/0'
  config.sidekiq_namespace = 'sidekiq'
end
