module Logging
  # Manually notifies Exception handler that an error has occured
  class ExceptionNotifier
    begin
      require 'rollbar'
    rescue LoadError
      STDERR.puts "#{name}: Unable to load 'rollbar' please include it in your Gemfile"
    end

    def self.notify(error, _additional_fields = {})
      notify_rollbar(error)
      notify_logger(error)
    end

    def self.notify_logger(exception)
      message = exception.message
      backtrace = exception.backtrace.try(:join, "\n")
      Logging.error "#{exception.class.name}\n#{message}\n#{backtrace}"
    end

    def self.notify_rollbar(error)
      return false unless defined?(Rollbar)
      Rollbar.error(error, use_exception_level_filters: true)
    end
  end
end
