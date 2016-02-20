require 'logging/version'
require 'logging/logstash_formatter'
require 'logging/exception_notifier'
require 'logging/railtie'

require 'logstash-event'

# Provides system Logging changes
module Logging
  %w( fatal error warn info debug unknown ).each do |severity|
    define_singleton_method severity do |message = nil, additional_fields = {}|
      if severity == 'unknown' || logger.send("#{severity}?")
        send(:log, severity, message, additional_fields)
      end
    end
  end

  class << self
    attr_writer :global_params

    def global_params
      @global_params ||= { host: Rails.env }
    end

    def logger
      @logger ||= Rails.application.config.logger || Rails.logger
    end

    # Report an exception to all reporting libraries
    def log_error(error, additional_fields = {})
      Logging::ExceptionNotifier.notify(error, additional_fields)
    end

    def logstash_formatter
      @logstash_formatter ||= Logging::LogStashFormatter.new
    end

    def skip_formatting!(&_block)
      old_formatting = Thread.current[:skip_logstash_formatting] || false
      Thread.current[:skip_logstash_formatting] = true
      yield
    ensure
      Thread.current[:skip_logstash_formatting] = old_formatting
    end

    def skip_formatting?
      Thread.current[:skip_logstash_formatting] || false
    end

    private

    def log(severity, message, additional_fields)
      fields = additional_fields.reverse_merge(global_params)
      event = LogStash::Event.new(fields)
      event['message'] = message
      event['@severity'] = severity.try(:upcase)

      skip_formatting! do
        logger << event.to_json + "\n"
      end
    end
  end
end
