require 'active_model'

module Security
  # Holds Configuration Variables for Security
  class Configuration
    include ActiveModel::Validations

    URL_HOST_REGEX = /\A\w+(\.\w+)*\z/

    attr_accessor :security_email_address
    attr_accessor :virtual_host
    attr_accessor :asset_host
    attr_accessor :ssl_enabled

    attr_reader :external_connect_sources
    attr_reader :external_font_sources
    attr_reader :external_frame_sources
    attr_reader :external_image_sources
    attr_reader :external_media_sources
    attr_reader :external_object_sources
    attr_reader :external_script_sources
    attr_reader :external_style_sources

    attr_reader :hpkp_public_keys

    alias ssl_enabled? ssl_enabled

    validates :virtual_host, format: { with: URL_HOST_REGEX, allow_nil: true }
    validates :asset_host, format: { with: URL_HOST_REGEX, allow_nil: true }
    validates :ssl_enabled, inclusion: { in: [true, false] }

    def initialize
      @external_connect_sources = []
      @external_font_sources = []
      @external_frame_sources = []
      @external_image_sources = []
      @external_media_sources = []
      @external_object_sources = []
      @external_script_sources = []
      @external_style_sources = []
      @hpkp_public_keys = []
    end

    def add_external_connect_source(connect_source)
      @external_connect_sources += Array[connect_source]
    end

    def add_external_font_source(font_source)
      @external_font_sources += Array[font_source]
    end

    def add_external_frame_source(frame_source)
      @external_frame_sources += Array[frame_source]
    end

    def add_external_image_source(image_source)
      @external_image_sources += Array[image_source]
    end

    def add_external_media_source(media_source)
      @external_media_sources += Array[media_source]
    end

    def add_external_object_source(object_source)
      @external_object_sources += Array[object_source]
    end

    def add_external_script_source(script_source)
      @external_script_sources += Array[script_source]
    end

    def add_external_style_source(style_source)
      @external_style_sources += Array[style_source]
    end

    def add_hpkp_public_key(public_key)
      @hpkp_public_keys += Array[public_key]
    end
  end
end
