Security.configure do |config|
  config.security_email_address = ::Settings.security_email_address
  config.virtual_host = ::Settings.virtual_host
  config.asset_host = ::Settings.asset_host
  config.ssl_enabled = ::Settings.ssl_enabled?

  # Connect
  # config.add_external_connect_source 'example.com'

  # Fonts
  config.add_external_font_source 'fonts.gstatic.com'

  # iframes
  # config.add_external_frame_source 'example.com

  # Images
  config.add_external_image_source 'secure.gravatar.com'
  config.add_external_image_source 'graph.facebook.com'
  config.add_external_image_source 'pbs.twimg.com'

  # Media
  # config.add_external_media_source 'example.com'

  # Objects
  # config.add_external_object_source 'outdated.legacy.com'

  # Scripts
  google_analytics_source = (config.ssl_enabled? ? 'ssl' : 'www') + '.google-analytics.com'
  config.add_external_script_source google_analytics_source
  if defined?(Jquery::Rails::Cdn)
    jquery_cdn_path = Object.new.tap { |o| o.extend(Jquery::Rails::Cdn) }.jquery_url(:google)
    config.add_external_script_source URI.parse(jquery_cdn_path).host
  end

  # Stylesheets
  config.add_external_style_source 'fonts.googleapis.com'
end
