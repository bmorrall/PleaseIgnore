class RemoveNullConstraintOnUsersEmail < ActiveRecord::Migration
  def up
    change_column :users, :email, :string, default: nil, null: true
  end

  def down
    change_column :users, :email, :string, default: '', null: false
  end
end
