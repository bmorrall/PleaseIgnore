require 'singleton'

# Provides Application-wide configuration variables
class Settings
  include Singleton

  class << self
    delegate :to_h, to: :instance
    delegate :hpkp_primary_key, :hpkp_backup_key, to: :instance

    # Adds a config_var
    # @param var_name [Symbol] registers a config value that will be displayed with inspect
    # @return void
    def config_var(var_name)
      config_vars << var_name
    end

    # @return [Array] returns all config vars
    def config_vars
      @config_vars ||= []
    end

    # Allows singleton methods to be used
    def method_missing(method_name, *_args, &_block)
      return super unless config_vars.include?(method_name)
      instance.public_send(method_name)
    end

    # Allows Method object to be returned (ruby 1.9+)
    def respond_to_missing?(method_name, _include_private = false)
      config_vars.include?(method_name) || super
    end

    # Allows for pretty inspect of safe variables
    def inspect
      "#{name} #{instance.inspect}"
    end
  end

  attr_reader :application

  delegate :secrets, to: :application

  def initialize(application = Rails.application)
    @application = application
  end

  # Returns a hash representation of safe variables
  def to_h
    Hash[self.class.config_vars.map { |var| [var, public_send(var)] }]
  end

  # Allows for pretty inspect of safe variables
  def inspect
    to_h.to_s
  end

  # Application

  def ssl_enabled?
    ENV['SSL_ENABLED'].present?
  end
  config_var :ssl_enabled?

  def virtual_host
    secrets.virtual_host.presence
  end
  config_var :virtual_host

  # Assets

  def asset_host
    secrets.asset_host.presence
  end
  config_var :asset_host

  def serve_static_files?
    ENV['RAILS_SERVE_STATIC_FILES'].present?
  end
  config_var :serve_static_files?

  # Background Jobs

  def sidekiq_enabled?
    redis_url.present? || Rails.env.test?
  end
  config_var :sidekiq_enabled?

  def redis_url
    secrets.redis_url.presence
  end
  config_var :redis_url

  # Analytics

  def google_analytics_id
    secrets.google_analytics['analytics_id'].presence
  end
  config_var :google_analytics_id

  # Rollbar

  def rollbar_access_token
    secrets.rollbar_access_token.presence
  end
  config_var :rollbar_access_token

  def rollbar_enabled?
    rollbar_access_token.present?
  end
  config_var :rollbar_enabled?

  # Email Addresses

  def accounts_email_address
    secrets.accounts_email_address.presence
  end
  config_var :accounts_email_address

  def contact_email_address
    secrets.contact_email_address.presence
  end
  config_var :contact_email_address

  def security_email_address
    secrets.security_email_address.presence || support_email_address
  end
  config_var :security_email_address

  def support_email_address
    secrets.support_email_address.presence
  end
  config_var :support_email_address

  # Security

  def hpkp_security_enabled?
    !!(hpkp_primary_key && hpkp_backup_key)
  end
  config_var :hpkp_security_enabled?

  def hpkp_primary_key
    secrets.hpkp_primary_key.presence
  end

  def hpkp_backup_key
    secrets.hpkp_backup_key.presence
  end
end
