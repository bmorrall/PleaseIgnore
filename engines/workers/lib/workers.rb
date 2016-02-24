require 'logging'
require 'workers/configuration'
require 'workers/railtie'

# Handles background workers and their configuration
module Workers
  HIGH_PRIORITY = :high_priority
  DEFAULT = :default
  LOW_PRIORITY = :low_priority
  MAILERS = :mailers

  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Workers::Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.sidekiq_config
    {
      namespace: configuration.sidekiq_namespace,
      network_timeout: 2,
      url: configuration.redis_url
    }
  end
end
