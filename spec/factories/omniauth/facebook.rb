FactoryGirl.define do
  factory :facebook_auth_hash, class: OmniAuth::AuthHash do
    skip_create

    transient do
      id { SecureRandom.random_number(1_000_000_000).to_s }
      name { "#{first_name} #{last_name}" }
      first_name { Faker::Name.first_name }
      last_name { Faker::Name.last_name }
      username { Faker::Internet.user_name(name) }
      email { Faker::Internet.email(username) }
      link { "http://www.facebook.com/#{username}" }
      image { "http://graph.facebook.com/#{id}/picture?type=square" }
      location_name 'Palo Alto, California'
      verified true

      token { SecureRandom.urlsafe_base64(100).delete('-_').first(100) }
      expires_at { SecureRandom.random_number(1.month.to_i).seconds.from_now }

      location_id '123456789'
      gender 'male'
      timezone(-8)
      locale 'en_US'
      updated_time { SecureRandom.random_number(1.month.to_i).seconds.ago }
    end

    provider 'facebook'
    uid { id }

    info do
      {
        nickname: username,
        email: email,
        name: name,
        first_name: first_name,
        last_name: last_name,
        image: image,
        urls: { Facebook: link },
        location: location_name,
        verified: verified
      }
    end

    credentials do
      {
        token: token,
        expires_at: expires_at.to_i,
        expires: true
      }
    end

    extra do
      {
        raw_info: {
          id: uid,
          name: name,
          first_name: first_name,
          last_name: last_name,
          link: link,
          username: username,
          location: { id: location_id, name: location_name },
          gender: gender,
          email: email,
          timezone: timezone,
          locale: locale,
          verified: verified,
          updated_time: updated_time.strftime('%FT%T%z')
        }
      }
    end
  end
end
