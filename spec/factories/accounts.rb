# == Schema Information
#
# Table name: accounts
#
#  id               :integer          not null, primary key
#  uid              :string(255)      not null
#  name             :string(255)
#  nickname         :string(255)
#  image            :string(255)
#  website          :string(255)
#  oauth_token      :string(255)
#  oauth_secret     :string(255)
#  oauth_expires_at :datetime
#  user_id          :integer
#  created_at       :datetime
#  updated_at       :datetime
#  position         :integer
#  type             :string(255)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :developer_account, class: Accounts::Developer do
    sequence(:uid) { |n| "uid_#{n}" }
    name { Faker::Name.name }
    user

    factory :facebook_account, class: Accounts::Facebook do
      image 'http://graph.facebook.com/1234567/picture?type=square'
      website 'http://www.facebook.com/jbloggs'
      sequence(:oauth_token) { |n| "facebook_auth_#{n}" }
      oauth_expires_at '2014-02-18 16:02:39'
      user
    end
    factory :github_account, class: Accounts::Github do
      nickname 'jonqpublic'
      image 'http://si0.twimg.com/sticky/default_profile_images/default_profile_2_normal.png'
      website 'https://github.com/johnqpublic'
      sequence(:oauth_token) { |n| "twitter_auth_#{n}" }
      sequence(:oauth_secret) { |n| "twitter_secret_#{n}" }
      user
    end
    factory :google_oauth2_account, class: Accounts::GoogleOauth2 do
      image 'https://lh3.googleusercontent.com/url/photo.jpg'
      sequence(:oauth_token) { |n| "twitter_auth_#{n}" }
      oauth_expires_at '2014-02-18 16:02:39'
      user
    end
    factory :twitter_account, class: Accounts::Twitter do
      nickname 'jonqpublic'
      image 'http://si0.twimg.com/sticky/default_profile_images/default_profile_2_normal.png'
      website 'https://twitter.com/johnqpublic'
      sequence(:oauth_token) { |n| "twitter_auth_#{n}" }
      sequence(:oauth_secret) { |n| "twitter_secret_#{n}" }
      user
    end
  end
end
