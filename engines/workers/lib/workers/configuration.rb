module Workers
  # Provides Configuration for Workers
  class Configuration
    attr_accessor :redis_url
    attr_writer :sidekiq_namespace

    def sidekiq_enabled?
      redis_url.present? || Rails.env.test?
    end

    def sidekiq_namespace
      @sidekiq_namespace ||= 'sidekiq'
    end
  end
end
