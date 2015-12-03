# Adds helpers for logging
module LoggingMacros
  def with_logging(&_block)
    old_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    begin
      yield
    ensure
      ActiveRecord::Base.logger = old_logger
    end
  end
end

RSpec.configure do |config|
  config.include LoggingMacros
end
