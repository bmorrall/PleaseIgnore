require 'lograge'
require 'logging/logstash_formatter'
require 'logging/passthrough_logger'
require 'logging/lograge_event_parser'
require 'logging/controller_logging'

module Logging
  # Mountable engine for Logging
  class Railtie < Rails::Railtie
    initializer 'logging.configure_logging' do |app|
      logger = Logging.logger

      # Replace the default logger with standarised logger
      logger.formatter = app.config.log_formatter = Logging.logstash_formatter

      # Setup lograge formatting
      config.lograge.enabled = true
      config.lograge.logger = Logging::PassthroughLogger.new(logger)
      config.lograge.formatter = Lograge::Formatters::Logstash.new
      config.lograge.custom_options = Logging::LogrageEventParser.new(Logging.global_params)
    end

    # Set whodunnint for non-ActionController changes
    rake_tasks do
      Logging.global_params[:request_id] = String(Process.pid)
    end
    runner do
      Logging.global_params[:request_id] = String(Process.pid)
    end
    console do
      Logging.global_params[:request_id] = String(Process.pid)
    end
  end
end
