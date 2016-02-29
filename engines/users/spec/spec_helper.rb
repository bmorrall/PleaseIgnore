require 'simplecov'
SimpleCov.minimum_coverage 80
SimpleCov.start

ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../dummy/config/environment.rb', __FILE__)
require 'rspec/rails'
require 'faker'
require 'factory_girl_rails'

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.mock_with :rspec
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false
  config.order = 'random'

  # Use FactoryGirl syntax methods (create, build, build_stubbed)
  config.include FactoryGirl::Syntax::Methods
end

require 'shoulda/matchers'
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :active_model
    with.library :active_record
  end
end
