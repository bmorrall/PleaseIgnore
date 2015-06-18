::SecureHeaders::Configuration.configure do |config|
  # Load the application host, or allow for relative paths
  application_domain = ENV.fetch('VIRTUAL_HOST', '')
  application_domain = "https://#{application_domain}" unless application_domain.blank?

  # Generic Secure Header Protection
  config.hsts = { max_age: 20.years.to_i, include_subdomains: true }
  config.x_frame_options = 'DENY'
  config.x_content_type_options = 'nosniff'
  config.x_xss_protection = { value: 1, mode: 'block' }
  config.x_download_options = 'noopen'
  config.x_permitted_cross_domain_policies = 'none'

  # Content Security Policy Headers
  config.csp = false

  # HTTP Public Key Pinning
  if Rails.application.secrets.hpkp_primary_key.blank? ||
     Rails.application.secrets.hpkp_backup_key.blank?
    config.hpkp = false
  else
    config.hpkp = {
      max_age: 60.days.to_i,
      include_subdomains: true,
      report_uri: "#{application_domain}/security/hpkp_report",
      pins: [
        { sha256: Rails.application.secrets.hpkp_primary_key },
        { sha256: Rails.application.secrets.hpkp_backup_key }
      ]
    }
  end
end
