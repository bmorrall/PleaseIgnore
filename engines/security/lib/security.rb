require 'secure_headers'
require 'rack/attack'

require 'security/engine'
require 'security/configuration'

# Provides a Security engine for PleaseIgnore
module Security
  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end
