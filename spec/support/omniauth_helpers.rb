# Provides helpers for handling OmniAuth
module OmniauthHelpers
  # Sets OmniAuth to accept provider login attempts by returning auth_hash
  def set_oauth(provider, auth_hash)
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[provider] = auth_hash
  end
end

RSpec.configure do |config|
  # Include OmniAuth helpers with omniauth tag
  config.include OmniauthHelpers, omniauth: true
end
