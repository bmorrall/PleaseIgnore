FactoryGirl.define do
  factory :papertrail_version, class: 'PaperTrail::Version' do
    event { %w(create update restore).sample }
    association :item, factory: :user
  end
end
