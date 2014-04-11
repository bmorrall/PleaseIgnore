# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :account do
    provider "developer"
    sequence(:uid) { |n| "uid_#{n}" }
    name { Faker::Name.name }
    user

    factory :developer_account do
      provider 'developer'
    end
    factory :facebook_account do
      provider 'facebook'
      image 'http://graph.facebook.com/1234567/picture?type=square'
      website 'http://www.facebook.com/jbloggs'
      sequence(:oauth_token) { |n| "facebook_auth_#{n}" }
      oauth_expires_at "2014-02-18 16:02:39"
      user
    end
    factory :github_account do
      provider 'github'
      nickname 'jonqpublic'
      image 'http://si0.twimg.com/sticky/default_profile_images/default_profile_2_normal.png'
      website 'https://github.com/johnqpublic'
      sequence(:oauth_token) { |n| "twitter_auth_#{n}" }
      sequence(:oauth_secret) { |n| "twitter_secret_#{n}" }
      user
    end
    factory :google_oauth2_account do
      provider 'google_oauth2'
      image 'https://lh3.googleusercontent.com/url/photo.jpg'
      sequence(:oauth_token) { |n| "twitter_auth_#{n}" }
      oauth_expires_at "2014-02-18 16:02:39"
      user
    end
    factory :twitter_account do
      provider 'twitter'
      nickname 'jonqpublic'
      image 'http://si0.twimg.com/sticky/default_profile_images/default_profile_2_normal.png'
      website 'https://twitter.com/johnqpublic'
      sequence(:oauth_token) { |n| "twitter_auth_#{n}" }
      sequence(:oauth_secret) { |n| "twitter_secret_#{n}" }
      user
    end
  end
end
