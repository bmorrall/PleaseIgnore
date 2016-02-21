require 'logstash-event'

module Logging
  # Wraps all log messages into a formatter
  class LogStashFormatter < ::ActiveSupport::Logger::SimpleFormatter
    include ActiveSupport::TaggedLogging::Formatter

    def call(severity, time, progname, msg)
      return super if Logging.skip_formatting? || severity == 'DEBUG'

      LogStash::Event.new(
        message: msg,
        :@severity => severity,
        :@progname => progname,
        :@tags => current_tags,
        :@timestamp => time
      ).to_json + "\n"
    end
  end
end
