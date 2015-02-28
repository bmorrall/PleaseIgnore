# Provides helpers for handling Omniauth
module OmniauthHelpers
  # Common auth account credentials
  def auth_account
    @auth_account ||= { name: 'Testy McSocial', email: 'testy@socialexample.com' }
  end

  # rubocop:disable AbcSize, MethodLength

  # @param provider [Symbol] name of provider to create credentials for
  # @return [Hash] Credentials for creating a provider auth hash
  def provider_credentials(provider)
    case provider.to_sym
    when :developer
      auth_account
    when :facebook
      facebook_credentials
    when :twitter
      twitter_credentials
    when :github
      github_credentials
    when :google_oauth2
      google_oauth2_credentials
    else
      fail "Unkown provider: #{provider}"
    end
  end

  # @param provider [Symbol] name of provider to create auth hash for
  # @return [Hash] OAuth Hash for representing a provider account
  def provider_auth_hash(provider)
    case provider.to_sym
    when :developer
      developer_auth_hash
    when :facebook
      facebook_auth_hash
    when :twitter
      twitter_auth_hash
    when :github
      github_auth_hash
    when :google_oauth2
      google_oauth2_hash
    else
      fail "Unkown provider: #{provider}"
    end
  end

  protected

  # Credential used for a Facebook Account
  def facebook_credentials
    @facebook_credentials ||=
      auth_account.merge(
        uid: '12345',
        image: 'http://graph.facebook.com/1234567/picture?type=square',
        website: 'http://www.facebook.com/jbloggs',
        oauth_token: 'ABCDEFGHJIKJLMNOP',
        oauth_expires_at: (Time.now + 2.hours).to_i
      ).freeze
  end

  # Credential used for a GitHub Account
  def github_credentials
    @github_credentials ||=
      auth_account.merge(
        uid: 'jonqpublic',
        nickname: 'jonqpublic',
        image: 'http://si0.twimg.com/sticky/default_profile_images/default_profile_2_normal.png',
        website: 'https://github.com/johnqpublic',
        oauth_token: 'ABCDEFGHJIKJLMNOP',
        oauth_secret: '0987654321'
      ).freeze
  end

  # Credential used for a Google Account
  def google_oauth2_credentials
    @google_oauth2_credentials ||=
      auth_account.merge(
        uid: 'jonqpublic',
        nickname: 'jonqpublic',
        image: 'https://lh3.googleusercontent.com/url/photo.jpg',
        oauth_token: 'ABCDEFGHJIKJLMNOP',
        oauth_expires_at: (Time.now + 2.hours).to_i
      ).freeze
  end

  # Credential used for a Twitter Account
  def twitter_credentials
    @twitter_credentials ||=
      auth_account.keep_if do |key|
        key != :email # Email is not included with Twitter oauth
      end.merge(
        uid: 'jonqpublic',
        nickname: 'jonqpublic',
        image: 'http://si0.twimg.com/sticky/default_profile_images/default_profile_2_normal.png',
        website: 'https://twitter.com/johnqpublic',
        oauth_token: 'ABCDEFGHJIKJLMNOP',
        oauth_secret: '0987654321'
      ).freeze
  end

  # Developer Auth uses Name and Email
  def developer_auth_hash
    OmniAuth::AuthHash.new(
      'uid' => auth_account[:email],
      'provider' => 'developer',
      'info' => {
        'name' => auth_account[:name],
        'email' => auth_account[:email]
      }
    )
  end

  # Facebook Auth Hash includes oauth credentials
  def facebook_auth_hash
    OmniAuth::AuthHash.new(
      'uid' => facebook_credentials[:uid],
      'provider' => 'facebook',
      'info' => {
        'name' => facebook_credentials[:name],
        'email' => facebook_credentials[:email],
        'image' => facebook_credentials[:image],
        'urls' => { 'Facebook' => facebook_credentials[:website] },
        'location' => 'Palo Alto, California',
        'verified' => true
      },
      'credentials' => {
        'token' => facebook_credentials[:oauth_token],
        'expires_at' => facebook_credentials[:oauth_expires_at],
        'expires' => true
      }
    )
  end

  # GitHub Auth Hash includes oauth credentials
  def github_auth_hash
    OmniAuth::AuthHash.new(
      'uid' => github_credentials[:uid],
      'provider' => 'github',
      'info' => {
        'name' => github_credentials[:name],
        'email' => github_credentials[:email],
        'nickname' => github_credentials[:nickname],
        'image' => github_credentials[:image],
        'urls' => { 'Github' => github_credentials[:website] },
        'location' => 'Anytown, USA',
        'verified' => true
      },
      'credentials' => {
        'token' => github_credentials[:oauth_token],
        'secret' => github_credentials[:oauth_secret]
      }
    )
  end

  # Google Auth Hash includes oauth credentials
  def google_oauth2_hash
    OmniAuth::AuthHash.new(
      'uid' => google_oauth2_credentials[:uid],
      'provider' => 'google_oauth2',
      'info' => {
        'name' => google_oauth2_credentials[:name],
        'email' => google_oauth2_credentials[:email],
        'image' => google_oauth2_credentials[:image]
      },
      'credentials' => {
        'token' => google_oauth2_credentials[:oauth_token],
        'refresh_token' => 'REFRESH12345',
        'expires_at' => google_oauth2_credentials[:oauth_expires_at],
        'expires' => true
      }
    )
  end

  # Twitter Auth Hash includes oauth credentials
  def twitter_auth_hash
    OmniAuth::AuthHash.new(
      'uid' => twitter_credentials[:uid],
      'provider' => 'twitter',
      'info' => {
        'name' => twitter_credentials[:name],
        'nickname' => twitter_credentials[:nickname],
        'image' => twitter_credentials[:image],
        'urls' => { 'Twitter' => twitter_credentials[:website] },
        'location' => 'Anytown, USA',
        'verified' => true
      },
      'credentials' => {
        'token' => twitter_credentials[:oauth_token],
        'secret' => twitter_credentials[:oauth_secret]
      }
    )
  end

  # rubocop:enable AbcSize, MethodLength

  def set_oauth(provider, auth_hash)
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[provider] = auth_hash
  end
end
