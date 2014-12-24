module DoubleVerificationMacros
  # Allows for stubbing of objects that don't have a associated method
  def skip_double_verification(&_block)
    RSpec::Mocks.configuration.verify_partial_doubles = false
    yield
  ensure
    RSpec::Mocks.configuration.verify_partial_doubles = true
  end
end

RSpec.configure do |config|
  config.include DoubleVerificationMacros
end
