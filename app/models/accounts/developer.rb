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

module Accounts
  # Developer Account
  class Developer < ::Account
    # Personal UID display, based off provider
    def account_uid
      uid
    end

    # Account Profile Picture
    # @return [String] Path to Account Profile Picture or nil
    def image
      Gravatar.gravatar_image_url(uid, 32)
    end

    # Common name for Account Provider
    def provider
      :developer
    end

    # Developer Accounts are never enabled for sign in
    # @return [Boolean] false always
    def enabled?
      false
    end
  end
end
