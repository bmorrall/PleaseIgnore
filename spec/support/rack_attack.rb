# Prevent rack-attack from limiting requests
RSpec.configure do |config|
  config.after(:each, type: :feature) do
    Rack::Attack.cache.store.clear
  end
  config.after(:each, type: :request) do
    Rack::Attack.cache.store.clear
  end
end
