# Provides helpers for handling OmniAuth
module OmniauthHelpers
  # @param provider [Symbol] name of provider to create auth hash for
  # @return [Hash] OAuth Hash for representing a provider account
  def provider_auth_hash(provider)
    send :"#{provider}_auth_hash"
  rescue NoMethodError
    raise "Unknown provider: #{provider}"
  end

  # Stubs OmniAuth to return `auth_hash` when a `provider` request is received
  def set_oauth(provider, auth_hash)
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[provider] = auth_hash
  end

  private

  # Developer Auth uses Name and Email
  def developer_auth_hash
    @developer_auth_hash ||= create(:developer_auth_hash, name: create_visitor[:name])
  end

  # Facebook Auth Hash includes oauth credentials
  def facebook_auth_hash
    @facebook_auth_hash ||= create(:facebook_auth_hash, name: create_visitor[:name])
  end

  # GitHub Auth Hash includes oauth credentials
  def github_auth_hash
    @github_auth_hash ||= create(:github_auth_hash, name: create_visitor[:name])
  end

  # Google Auth Hash includes oauth credentials
  def google_oauth2_auth_hash
    @google_oauth2_auth_hash ||= create(:google_oauth2_auth_hash, name: create_visitor[:name])
  end

  # Twitter Auth Hash includes oauth credentials
  def twitter_auth_hash
    @twitter_account ||= create(:twitter_auth_hash, name: create_visitor[:name])
  end
end

World(OmniauthHelpers)
