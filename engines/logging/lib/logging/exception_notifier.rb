module Logging
  # Manually notifies Exception handler that an error has occured
  class ExceptionNotifier
    begin
      require 'rollbar'
    rescue LoadError
      STDERR.puts "#{name}: Unable to load 'rollbar' please include it in your Gemfile"
    end

    def self.notify(error, additional_fields = {})
      notify_rollbar(error, additional_fields)
      notify_logger(error, additional_fields)
    end

    def self.notify_logger(exception, additional_fields)
      message = exception.message
      backtrace = exception.backtrace.try(:join, "\n")
      Logging.error "#{exception.class.name}\n#{message}\n#{backtrace}", additional_fields
    end

    def self.notify_rollbar(error, additional_fields)
      return false unless defined?(Rollbar)
      Rollbar.error(error, additional_fields.reverse_merge(use_exception_level_filters: true))
    end
  end
end
