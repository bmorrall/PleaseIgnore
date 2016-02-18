module Security
  # Mountable engine for Security Callbacks
  class Engine < ::Rails::Engine
    isolate_namespace Security
    engine_name :security

    initializer 'security.add_secure_headers' do
      ::SecureHeaders::Configuration.default do |config|
        # Generic Secure Header Protection
        config.hsts = 'max-age=631152000; includeSubdomains'
        config.x_frame_options = 'DENY'
        config.x_content_type_options = 'nosniff'
        config.x_xss_protection = '1; mode=block'
        config.x_download_options = 'noopen'
        config.x_permitted_cross_domain_policies = 'none'

        # Content Security Policy Headers
        config.csp = Security::CspRulesetBuilder.build

        # HTTP Public Key Pinning
        config.hpkp = Security::HpkpRulesetBuilder.build
      end
    end

    initializer 'security.add_rack_attack' do |app|
      # Use Rack::Attack to secure critical points against attacks
      app.middleware.use Rack::Attack

      # Prevent the csp report from being flooded
      Rack::Attack.throttle('security/csp_report', limit: 5, period: 1.minute) do |req|
        req.ip if req.path.starts_with?(Security::Engine.routes.url_helpers.csp_report_path)
      end

      # Prevent the hpkp report from being flooded
      Rack::Attack.throttle('security/hpkp_report', limit: 5, period: 1.minute) do |req|
        req.ip if req.path.starts_with?(Security::Engine.routes.url_helpers.hpkp_report_path)
      end

      # By default, Rack::Attack returns an HTTP 429 for throttled responses,
      # which is just fine.
      #
      # If you want to return 503 so that the attacker might be fooled into
      # believing that they've successfully broken your app (or you just want to
      # customize the response), then uncomment these lines.
      Rack::Attack.throttled_response = lambda do |env|
        status = 429 # Too Many Requests
        headers = { 'Retry-After' => env['rack.attack.match_data'][:period] }
        body = {
          status: status,
          error: I18n.t('security.rack_attack.limit_exceeded_message')
        }

        [429, headers, [body.to_json]]
      end
    end

    config.after_initialize do
      config = Security.configuration
      unless config.valid?
        raise "Invalid security configuration: #{config.errors.messages.inspect}"
      end
    end

    config.generators do |g|
      g.test_framework :rspec, fixture: false
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
      g.assets false
      g.helper false
    end
  end
end
