require 'settings'

module Security
  # Builds a Content Security Policy Ruleset
  class CspRulesetBuilder
    SELF = "'self'".freeze
    NONE = "'none'".freeze

    # Buils a new CSB Ruleset that limits the application down
    def self.build(settings: ::Settings.instance)
      new(settings: settings).build
    end

    delegate :virtual_host, :asset_host, :ssl_enabled?, to: :settings

    attr_reader :settings

    def initialize(settings:)
      @settings = settings
    end

    def build
      {
        enforce: true,
        default_src: default_csp_params,
        base_uri: base_uri,
        block_all_mixed_content: false,
        # see [http://www.w3.org/TR/mixed-content/](http://www.w3.org/TR/mixed-content/)
        child_src: [NONE],
        # connect_src: %w(wws:),
        font_src: font_src,
        form_action: [SELF],
        frame_ancestors: [NONE],
        frame_src: frame_src,
        img_src: img_src,
        # media_src: [asset_host_or_self],
        object_src: [NONE],
        # plugin_types: NONE,
        script_src: script_src,
        style_src: style_src,
        report_uri: [report_uri]
      }
    end

    def default_csp_params
      @default_csp_params ||= ["#{protocol}:", asset_host_or_self]
    end

    def base_uri
      @base_uri ||= Array.wrap(application_domain || SELF)
    end

    def font_src
      @font_src ||= default_csp_params + %w(data:) + external_font_sources
    end

    def frame_src
      @frame_src ||= [NONE]
    end

    def img_src
      @img_src ||= %w(data:) + default_csp_params + external_image_sources
    end

    def report_uri
      @report_uri ||= "#{application_domain}/security/csp_report"
    end

    def script_src
      @script_src ||= default_csp_params + external_script_sources
    end

    def style_src
      @style_src ||= default_csp_params + %w('unsafe-inline') + external_style_sources
    end

    def application_domain
      @application_domain ||= "#{protocol}://#{virtual_host}" if virtual_host
    end

    def asset_host_or_self
      @asset_host_or_self = asset_host || SELF
    end

    def jquery_cdn_host
      @jquery_cdn_host ||= URI.parse(jquery_cdn_path).host
    end

    private

    def external_image_sources
      %w(
        secure.gravatar.com
        graph.facebook.com
        pbs.twimg.com
      )
    end

    def external_font_sources
      %w(
        fonts.gstatic.com
      )
    end

    def external_script_sources
      ga_source = (ssl_enabled? ? 'ssl' : 'www') + '.google-analytics.com'
      [
        ga_source,
        jquery_cdn_host
      ]
    end

    def external_style_sources
      %w(
        fonts.googleapis.com
      )
    end

    def protocol
      @protocol ||= ssl_enabled? ? 'https' : 'http'
    end

    # @return [String] path used to load jQuery from cdn
    def jquery_cdn_path
      @jquery_cdn_path ||= Object.new.tap { |o| o.extend(Jquery::Rails::Cdn) }.jquery_url(:google)
    end
  end
end
