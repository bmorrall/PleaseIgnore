class CreateOrganisations < ActiveRecord::Migration
  def change
    create_table :organisations do |t|
      t.string :name
      t.string :permalink

      t.timestamps null: false
    end
    add_index :organisations, :permalink, unique: true
  end
end
