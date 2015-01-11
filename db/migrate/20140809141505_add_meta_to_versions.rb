class AddMetaToVersions < ActiveRecord::Migration
  def change
    change_table :versions do |t|
      t.text   :meta # Store for meta attributes
      t.text   :object_changes # Store for Object changes
    end
  end
end
