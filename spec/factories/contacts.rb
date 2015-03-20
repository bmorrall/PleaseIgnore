
FactoryGirl.define do
  factory :contact do
    skip_create

    name { Faker::Name.name }
    email { Faker::Internet.email(name) }
    body 'Example Contact Body'
  end
end
