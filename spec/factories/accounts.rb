# == Schema Information
#
# Table name: accounts
#
#  id               :integer          not null, primary key
#  uid              :string           not null
#  name             :string
#  nickname         :string
#  image            :string
#  website          :string
#  oauth_token      :string
#  oauth_secret     :string
#  oauth_expires_at :datetime
#  user_id          :integer
#  created_at       :datetime
#  updated_at       :datetime
#  position         :integer
#  type             :string
#  deleted_at       :datetime
#
# Indexes
#
#  index_accounts_on_deleted_at  (deleted_at)
#  index_accounts_on_user_id     (user_id)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :account, class: Accounts::Developer do
    transient do
      auth_hash { create :developer_auth_hash }
    end

    uid { auth_hash.uid }
    name { auth_hash.info.name }
    user

    trait :soft_deleted do
      deleted_at { DateTime.now }
    end

    factory :developer_account do
      email { auth_hash.info.email }
    end

    factory :facebook_account, class: Accounts::Facebook do
      transient do
        auth_hash { create :facebook_auth_hash }
      end

      email { auth_hash.info.email }
      image { auth_hash.info.image }
      website { auth_hash.info.urls[:Facebook] }
      oauth_token { auth_hash.credentials.token }
      oauth_expires_at { Time.at(auth_hash.credentials.expires_at).to_datetime }
    end

    factory :github_account, class: Accounts::Github do
      transient do
        auth_hash { create :github_auth_hash }
      end

      email { auth_hash.info.email }
      nickname { auth_hash.info.nickname }
      image { auth_hash.info.image }
      website { auth_hash.info.urls[:Github] }
      oauth_token { auth_hash.credentials.token }
      oauth_secret { auth_hash.credentials.secret }
    end

    factory :google_oauth2_account, class: Accounts::GoogleOauth2 do
      transient do
        auth_hash { create :google_oauth2_auth_hash }
      end

      email { auth_hash.info.email }
      image { auth_hash.info.image }
      oauth_token { auth_hash.credentials.token }
      oauth_expires_at { Time.at(auth_hash.credentials.expires_at).to_datetime }
    end

    factory :twitter_account, class: Accounts::Twitter do
      transient do
        auth_hash { create :twitter_auth_hash }
      end

      nickname { auth_hash.info.nickname }
      image { auth_hash.info.image }
      website { auth_hash.info.urls[:Twitter] }
      oauth_token { auth_hash.credentials.token }
      oauth_secret { auth_hash.credentials.secret }
    end
  end
end
