class AddPositionToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :position, :integer
  end
end
