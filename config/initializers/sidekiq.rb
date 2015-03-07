if Rails.application.secrets.redis_url
  redis_config = {
    namespace: 'sidekiq',
    url: Rails.application.secrets.redis_url
  }

  Sidekiq.configure_server do |config|
    config.redis = redis_config
  end

  Sidekiq.configure_client do |config|
    config.redis = redis_config
  end
end
