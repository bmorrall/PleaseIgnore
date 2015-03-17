class AddItemOwnerToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :item_owner_id, :integer
    add_column :versions, :item_owner_type, :string
    add_index :versions, [:item_owner_id, :item_owner_type]
  end
end
