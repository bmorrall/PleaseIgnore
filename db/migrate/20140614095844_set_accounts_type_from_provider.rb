class Account < ActiveRecord::Base; end

class SetAccountsTypeFromProvider < ActiveRecord::Migration
  def change
    Account.where(type: nil).each do |account|
      account.update_attribute :type, "Accounts::#{account.provider.classify}" if account.provider?
    end
  end
end
