
FactoryGirl.define do
  factory :contact do
    skip_create

    name { Faker::Name.name }
    email { Faker::Internet.email }
    body 'Example Contact Body'
  end
end
