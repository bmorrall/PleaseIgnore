module OmniauthHelpers

  def auth_account
    @auth_account ||= { :name => 'Testy McSocial', email: 'testy@socialexample.com' }
  end

  def facebook_credentials
    @facebook_credentials ||= {
      :uid => '12345',
      :name => auth_account[:name],
      :image => 'http://graph.facebook.com/1234567/picture?type=square',
      :website => 'http://www.facebook.com/jbloggs',
      :oauth_token => 'ABCDEFGHJIKJLMNOP',
      :oauth_expires_at => (Time.now + 2.hours).to_i
    }
  end

  def github_credentials
    @github_credentials ||= {
      :uid => 'jonqpublic',
      :name => auth_account[:name],
      :nickname => 'jonqpublic',
      :image => "http://si0.twimg.com/sticky/default_profile_images/default_profile_2_normal.png",
      :website => "https://github.com/johnqpublic",
      :oauth_token => 'ABCDEFGHJIKJLMNOP',
      :oauth_secret => '0987654321'
    }
  end

  def google_credentials
    @google_credentials ||= {
      :uid => 'jonqpublic',
      :name => auth_account[:name],
      :nickname => 'jonqpublic',
      :image => "https://lh3.googleusercontent.com/url/photo.jpg",
      :oauth_token => 'ABCDEFGHJIKJLMNOP',
      :oauth_expires_at => (Time.now + 2.hours).to_i
    }
  end

  def twitter_credentials
    @twitter_credentials ||= {
      :uid => 'jonqpublic',
      :name => auth_account[:name],
      :nickname => 'jonqpublic',
      :image => "http://si0.twimg.com/sticky/default_profile_images/default_profile_2_normal.png",
      :website => "https://twitter.com/johnqpublic",
      :oauth_token => 'ABCDEFGHJIKJLMNOP',
      :oauth_secret => '0987654321'
    }
  end

  # Developer Auth uses Name and Email
  def developer_auth_hash
    auth_account
    OmniAuth::AuthHash.new({
      'uid' => @auth_account[:email],
      'provider' => 'developer',
      'info' => {
        'name' => @auth_account[:name],
        'email' => @auth_account[:email]
      }
    })
  end

  # Facebook Auth Hash includes oauth credentials
  def facebook_auth_hash
    auth_account
    facebook_credentials

    OmniAuth::AuthHash.new({
      'uid' => @facebook_credentials[:uid],
      'provider' => 'facebook',
      'info' => {
        'name' => @facebook_credentials[:name],
        'email' => @auth_account[:email],
        'image' => @facebook_credentials[:image],
        'urls' => { 'Facebook' => @facebook_credentials[:website] },
        'location' => 'Palo Alto, California',
        'verified' => true
      },
      'credentials' => {
        'token' => @facebook_credentials[:oauth_token],
        'expires_at' => @facebook_credentials[:oauth_expires_at],
        'expires' => true
      }
    })
  end

  # GitHub Auth Hash includes oauth credentials
  def github_auth_hash
    auth_account
    github_credentials

    OmniAuth::AuthHash.new({
      'uid' => @github_credentials[:uid],
      'provider' => 'github',
      'info' => {
        'name' => @github_credentials[:name],
        'email' => @auth_account[:email],
        'nickname' => @github_credentials[:nickname],
        'image' => @github_credentials[:image],
        'urls' => { 'Github' => @github_credentials[:website] },
        'location' => 'Anytown, USA',
        'verified' => true
      },
      'credentials' => {
        'token' => @github_credentials[:oauth_token],
        'secret' => @github_credentials[:oauth_secret]
      }
    })
  end

  # Google Auth Hash includes oauth credentials
  def google_auth_hash
    auth_account
    google_credentials

    OmniAuth::AuthHash.new({
      'uid' => @google_credentials[:uid],
      'provider' => 'google_oauth2',
      'info' => {
        'name' => @google_credentials[:name],
        'email' => @auth_account[:email],
        'image' => @google_credentials[:image],
      },
      'credentials' => {
        'token' => @google_credentials[:oauth_token],
        'refresh_token' => 'REFRESH12345',
        'expires_at' => @google_credentials[:oauth_expires_at],
        'expires' => true
      }
    })
  end

  # Twitter Auth Hash includes oauth credentials
  def twitter_auth_hash
    auth_account
    twitter_credentials

    OmniAuth::AuthHash.new({
      'uid' => @twitter_credentials[:uid],
      'provider' => 'twitter',
      'info' => {
        'name' => @twitter_credentials[:name],
        'nickname' => @twitter_credentials[:nickname],
        'image' => @twitter_credentials[:image],
        'urls' => { 'Twitter' => @twitter_credentials[:website] },
        'location' => 'Anytown, USA',
        'verified' => true
      },
      'credentials' => {
        'token' => @twitter_credentials[:oauth_token],
        'secret' => @twitter_credentials[:oauth_secret]
      }
    })
  end

  def set_oauth(provider, auth_hash)
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[provider] = auth_hash
  end

end