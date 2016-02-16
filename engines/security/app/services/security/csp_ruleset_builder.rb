module Security
  # Builds a Content Security Policy Ruleset for SecureHeaders
  class CspRulesetBuilder
    SELF = "'self'".freeze
    NONE = "'none'".freeze

    # Buils a new CSB Ruleset that limits the application down
    def self.build(configuration: Security.configuration)
      new(configuration: configuration).send(:build)
    end

    private_class_method :new

    delegate :virtual_host,
             :asset_host,
             :ssl_enabled?,
             :external_connect_sources,
             :external_font_sources,
             :external_frame_sources,
             :external_image_sources,
             :external_media_sources,
             :external_object_sources,
             :external_script_sources,
             :external_style_sources,
             to: :configuration

    attr_reader :configuration

    def initialize(configuration:)
      @configuration = configuration
    end

    protected

    # rubocop:disable Metrics/MethodLength

    def build
      {
        enforce: true,
        default_src: default_csp_params,
        connect_src: connect_src,
        font_src: font_src,
        frame_src: frame_src,
        img_src: img_src,
        media_src: media_src,
        object_src: object_src,
        script_src: script_src,
        style_src: style_src,
        report_uri: [report_uri]
      }
    end

    # rubocop:enable Metrics/MethodLength

    def default_csp_params
      @default_csp_params ||= ["#{protocol}:", asset_host_or_self]
    end

    def connect_src
      @connect_src ||= [SELF, asset_host, external_connect_sources].flatten.compact
    end

    def font_src
      @font_src ||= default_csp_params + %w(data:) + external_font_sources
    end

    def frame_src
      @frame_src ||= external_frame_sources.empty? ? [NONE] : external_frame_sources
    end

    def img_src
      @img_src ||= %w(data:) + default_csp_params + external_image_sources
    end

    def media_src
      @media_src ||= default_csp_params + external_media_sources
    end

    def object_src
      @object_src ||= external_object_sources.empty? ? [NONE] : external_object_sources
    end

    def script_src
      @script_src ||= default_csp_params + external_script_sources
    end

    def style_src
      @style_src ||= default_csp_params + %w('unsafe-inline') + external_style_sources
    end

    def report_uri
      @report_uri ||= "#{application_domain}/security/csp_report"
    end

    def application_domain
      @application_domain ||= "#{protocol}://#{virtual_host}" if virtual_host
    end

    def asset_host_or_self
      @asset_host_or_self = asset_host || SELF
    end

    private

    def protocol
      @protocol ||= ssl_enabled? ? 'https' : 'http'
    end
  end
end
