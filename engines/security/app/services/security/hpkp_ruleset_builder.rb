module Security
  # Builds a HTTP Public Key Pinning Ruleset for SecureHeaders
  class HpkpRulesetBuilder
    def self.build(configuration: Security.configuration)
      new(configuration: configuration).send(:build)
    end

    private_class_method :new

    protected

    attr_reader :configuration

    delegate :virtual_host,
             :ssl_enabled?,
             :hpkp_public_keys,
             to: :configuration

    def initialize(configuration:)
      @configuration = configuration
    end

    def build
      return SecureHeaders::OPT_OUT unless hpkp_enabled?

      {
        report_only: false,
        max_age: 60.days.to_i,
        include_subdomains: true,
        report_uri: report_uri,
        pins: hpkp_public_key_pins
      }
    end

    def hpkp_enabled?
      hpkp_public_keys.count >= 2
    end

    def hpkp_public_key_pins
      @hpkp_public_key_pins ||= hpkp_public_keys.map { |hpkp_key| { sha256: hpkp_key } }
    end

    def report_uri
      @report_uri ||= "#{application_domain}/security/hpkp_report"
    end

    def application_domain
      @application_domain ||= "#{protocol}://#{virtual_host}" if virtual_host
    end

    private

    def protocol
      @protocol ||= ssl_enabled? ? 'https' : 'http'
    end
  end
end
