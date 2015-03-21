FactoryGirl.define do
  factory :google_oauth2_auth_hash, class: OmniAuth::AuthHash do
    skip_create

    transient do
      id { SecureRandom.random_number(1_000_000_000).to_s }
      name { Faker::Name.name }
      email { Faker::Internet.email(name) }
      image { 'https://lh3.googleusercontent.com/url/photo.jpg' }

      token { SecureRandom.urlsafe_base64(100).delete('-_').first(100) }
      refresh_token { SecureRandom.urlsafe_base64(100).delete('-_').first(100) }
      expires_at { SecureRandom.random_number(1.month.to_i).seconds.from_now.to_i }
    end

    provider 'google_oauth2'
    uid { id }

    info do
      {
        name: name,
        email: email,
        image: image
      }
    end

    credentials do
      {
        token: token,
        refresh_token: refresh_token,
        expires_at: expires_at,
        expires: true
      }
    end
  end
end
