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

module Accounts
  # Developer Account
  class Developer < ::Account
    # Personal UID display, based off provider
    def account_uid
      uid
    end

    # Account Profile Picture
    # @param [Fixnum] _size Preferred size of the image
    # @return [String] Path to Account Profile Picture or nil
    def profile_picture(_size = 128)
      nil
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
