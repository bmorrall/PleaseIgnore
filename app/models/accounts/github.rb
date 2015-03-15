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
