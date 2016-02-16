module Security
  # Notifies all known Error Handlers, that a bug has occured
  class NotifyErrorHandlers
    def self.call(e)
      new(e).tap(&:call)
    end

    attr_reader :error

    def initialize(error)
      @error = error
    end

    def call
      notify_rollbar if defined?(Rollbar)
    end

    protected

    def notify_rollbar
      Rollbar.error(error, use_exception_level_filters: true)
    end
  end
end
