module Logging
  # Creates a wrapper for a Logger that doesn't wrap the message in a LogStash wrapper
  class PassthroughLogger
    def initialize(logger)
      @logger = logger
    end

    %w( fatal error warn info debug unknown ).each do |severity|
      define_method severity do |*args|
        Logging.skip_formatting! do
          @logger.send(severity, *args)
        end
      end
    end
  end
end
