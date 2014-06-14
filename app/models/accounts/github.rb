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
  # GitHub Account
  class Github < ::Account
    # Personal UID display, based off provider
    def account_uid
      if nickname?
        nickname
      elsif name?
        name
      else
        uid
      end
    end

    # Common name for Account Provider
    def provider
      :github
    end

    protected

    # Updates Common Account information
    def update_account_info(info)
      super
      urls = info['urls']
      self.website = urls && urls['Github']
    end
  end
end
