class AddForeignKeys < ActiveRecord::Migration
  def change
    add_foreign_key :accounts, :users, name: 'fk_accounts_users'
    add_foreign_key :users_roles, :roles, name: 'fk_users_roles_roles'
    add_foreign_key :users_roles, :users, name: 'fk_users_roles_users'
  end
end
