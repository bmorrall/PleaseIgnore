FactoryGirl.define do
  factory :github_auth_hash, class: OmniAuth::AuthHash do
    skip_create

    transient do
      id { SecureRandom.random_number(1_000_000_000).to_s }
      username { Faker::Internet.user_name(name) }
      name { Faker::Name.name }
      email { Faker::Internet.email(username) }
      image { 'http://si0.twimg.com/sticky/default_profile_images/default_profile_2_normal.png' }
      link { "https://github.com/#{username}" }
      location_name 'Palo Alto, California'
      verified true

      token { SecureRandom.urlsafe_base64(100).delete('-_').first(100) }
      secret { SecureRandom.urlsafe_base64(100).delete('-_').first(100) }
    end

    provider 'github'
    uid { id }

    info do
      {
        nickname: username,
        email: email,
        name: name,
        image: image,
        urls: { Github: link },
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
