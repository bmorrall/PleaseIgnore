class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :provider, null: false
      t.string :uid, null: false
      t.string :name
      t.string :nickname
      t.string :image
      t.string :website
      t.string :oauth_token
      t.string :oauth_secret
      t.datetime :oauth_expires_at
      t.references :user, index: true

      t.timestamps null: true
    end
    add_index :accounts, [:provider, :uid], unique: true
  end
end
