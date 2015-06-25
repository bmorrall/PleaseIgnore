Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.
  application_domain = ENV.fetch('VIRTUAL_HOST', Rails.env)

  # Configure Sendgrid
  if ENV['CI']
    ActionMailer::Base.smtp_settings = {
      address: ENV['MAILCATCHER_PORT_1025_TCP_ADDR'],
      port: ENV['MAILCATCHER_PORT_1025_TCP_PORT'],
      domain: application_domain
    }
  else
    ActionMailer::Base.smtp_settings = {
      user_name: ENV['SENDGRID_USERNAME'],
      password: ENV['SENDGRID_PASSWORD'],
      domain: application_domain,
      address: 'smtp.sendgrid.net',
      port: 587,
      authentication: :plain,
      enable_starttls_auto: true
    }
  end

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Enable Rack::Cache to put a simple HTTP cache in front of your application
  # Add `rack-cache` to your Gemfile before enabling this.
  # For large-scale production use, consider using a caching reverse proxy like
  # NGINX, varnish or squid.
  # config.action_dispatch.rack_cache = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.serve_static_files = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = :uglifier
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX
  unless ENV['RAILS_SERVE_STATIC_FILES'].present?
    config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX
  end

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true if ENV['SSL_ENABLED']

  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = :debug

  # Prepend all log lines with the following tags.
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups.
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use memcached in production.
  dalli_options = {
    namespace: 'please_ignore_cache',
    compress: true,
    expires_in: 1.day,
    raise_errors: false,
    socket_timeout: 1.5,
    socket_failure_delay: 0.2
  }
  if ENV['MEMCACHIER_SERVERS']
    # [Heroku] Use Memcachier service
    config.cache_store = :dalli_store, ENV['MEMCACHIER_SERVERS'].split(','), {
      username: ENV['MEMCACHIER_USERNAME'],
      password: ENV['MEMCACHIER_PASSWORD'],
      failover: true
    }.reverse_merge(dalli_options)
  else
    # [Docker] Use Memcached on localhost
    config.cache_store = :dalli_store, nil, dalli_options
  end

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = 'http://assets.example.com'
  unless Rails.application.secrets.asset_host.blank?
    config.action_controller.asset_host = Rails.application.secrets.asset_host
  end

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Set the default url host
  config.action_mailer.default_url_options = { host: application_domain }
end
