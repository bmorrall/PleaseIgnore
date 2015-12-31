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
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_deleted_at            (deleted_at)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email(name) }
    name { Faker::Name.name }
    password 'changeme'
    password_confirmation 'changeme'

    # Role Traits
    trait(:admin) do
      after(:create) { |user| user.add_role :admin }
    end
    trait(:banned) do
      after(:create) { |user| user.add_role :banned }
    end
    trait(:confirmed) do
      confirmed_at { Time.zone.now }
    end
    trait(:no_login_password) do
      email nil
      password nil
      password_confirmation nil
      after(:build) { |user| user.new_session_accounts << build(:developer_account) }
      after(:create) { |user| user.update_column :encrypted_password, '' }
    end

    trait :soft_deleted do
      deleted_at { DateTime.now }
    end
  end
end
