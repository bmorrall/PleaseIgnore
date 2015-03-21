FactoryGirl.define do
  factory :twitter_auth_hash, class: OmniAuth::AuthHash do
    skip_create

    transient do
      id { username }
      name { Faker::Name.name }
      username { Faker::Internet.user_name(name, ['']) }
      image { "http://graph.twitter.com/#{id}/picture?type=square" }
      link { "https://twitter.com/#{username}" }
      location_name 'Palo Alto, California'
      verified true

      token { SecureRandom.urlsafe_base64(100).delete('-_').first(100) }
      secret { SecureRandom.urlsafe_base64(100).delete('-_').first(100) }
    end

    provider 'twitter'
    uid { id }

    info do
      {
        name: name,
        nickname: username,
        image: image,
        urls: { Twitter: link },
        location: location_name,
        verified: verified
      }
    end

    credentials do
      {
        token: token,
        secret: secret
      }
    end
  end
end
