FactoryGirl.define do
  factory :developer_auth_hash, class: OmniAuth::AuthHash do
    skip_create

    transient do
      id { email }
      name { Faker::Name.name }
      email { Faker::Internet.email(name) }
    end

    provider 'developer'
    uid { id }

    info do
      {
        email: email,
        name: name
      }
    end
  end
end
