class SetAccountsTypeFromProvider < ActiveRecord::Migration
  class BaseAccount < ActiveRecord::Base;
    self.table_name = :accounts
  end

  def change
    BaseAccount.where(type: nil).each do |account|
      account.update_attribute :type, "Accounts::#{account.provider.classify}" if account.provider?
    end
  end
end
