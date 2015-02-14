redis_domain = ENV['REDIS_PORT_6379_TCP_ADDR']  
redis_port   = ENV['REDIS_PORT_6379_TCP_PORT']

if redis_domain && redis_port
  redis_url = "redis://#{redis_domain}:#{redis_port}/0"

  redis_config = {
    namespace: "sidekiq",
    url: redis_url
  }

  Sidekiq.configure_server do |config|
    config.redis = redis_config
  end

  Sidekiq.configure_client do |config|
    config.redis = redis_config
  end
end

