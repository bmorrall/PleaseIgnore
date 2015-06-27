FactoryGirl.define do
  factory :papertrail_version, class: 'PaperTrail::Version' do
    event { %w(create update restore).sample }
    association :item, factory: :user

    trait :with_user_agent do
      ip { Faker::Internet.ip_v4_address }
      user_agent { Faker::Internet.user_agent }
    end
  end
end
