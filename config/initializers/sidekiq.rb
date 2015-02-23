redis_url = ENV['REDIS_URL']

if redis_url
  redis_config = {
    namespace: 'sidekiq',
    url: redis_url
  }

  Sidekiq.configure_server do |config|
    config.redis = redis_config
  end

  Sidekiq.configure_client do |config|
    config.redis = redis_config
  end
end
