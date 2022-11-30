class CreateLocalMetadata < ActiveRecord::Migration[7.0]
  def change
    create_table :local_metadata do |t|
      t.string :cm_local_pref_label

      t.timestamps
    end
    add_index :local_metadata, :cm_local_pref_label
  end
end
