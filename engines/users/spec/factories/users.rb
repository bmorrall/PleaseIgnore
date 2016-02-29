# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  name                   :string
#  created_at             :datetime
#  updated_at             :datetime
#  deleted_at             :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email(name) }
    name { Faker::Name.name }
    password 'changeme'
    password_confirmation { password }

    trait(:confirmed) do
      confirmed_at { Time.zone.now }
    end
    trait :soft_deleted do
      deleted_at { DateTime.now }
    end
    trait(:expired) do
      deleted_at { User::EXPIRATION_PERIOD.ago }
    end
  end
end
