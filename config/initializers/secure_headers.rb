require 'security/csp_ruleset_builder'

::SecureHeaders::Configuration.default do |config|
  # Generic Secure Header Protection
  config.hsts = ::Settings.ssl_enabled? && { max_age: 20.years.to_i, include_subdomains: true }
  config.x_frame_options = 'DENY'
  config.x_content_type_options = 'nosniff'
  config.x_xss_protection = '1; mode=block'
  config.x_download_options = 'noopen'
  config.x_permitted_cross_domain_policies = 'none'

  # Content Security Policy Headers
  config.csp = Security::CspRulesetBuilder.build(settings: ::Settings.instance)

  # HTTP Public Key Pinning
  if ::Settings.hpkp_security_enabled?
    # Load the application host, or allow for relative paths
    protocol = ::Settings.ssl_enabled? ? 'https' : 'http'
    virtual_host = ::Settings.virtual_host
    application_domain = "#{protocol}://#{virtual_host}" if virtual_host

    config.hpkp = {
      enforce: true,
      max_age: 60.days.to_i,
      include_subdomains: true,
      report_uri: "#{application_domain}/security/hpkp_report",
      pins: [
        { sha256: ::Settings.hpkp_primary_key },
        { sha256: ::Settings.hpkp_backup_key }
      ]
    }
  else
    config.hpkp = false
  end
end
