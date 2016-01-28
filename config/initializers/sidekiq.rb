require 'settings'

if ::Settings.redis_url
  redis_config = {
    namespace: 'sidekiq',
    network_timeout: 2,
    url: ::Settings.redis_url
  }

  Sidekiq.configure_server do |config|
    config.redis = redis_config
  end

  Sidekiq.configure_client do |config|
    config.redis = redis_config
  end
end
