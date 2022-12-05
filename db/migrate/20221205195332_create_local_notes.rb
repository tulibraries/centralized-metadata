class CreateLocalNotes < ActiveRecord::Migration[7.0]
  def change
    create_table :local_notes do |t|
      t.references :local_metadatum, null: false, foreign_key: true
      t.string :cm_local_note

      t.timestamps
    end
  end
end
