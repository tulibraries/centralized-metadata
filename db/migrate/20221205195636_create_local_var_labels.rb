class CreateLocalVarLabels < ActiveRecord::Migration[7.0]
  def change
    create_table :local_var_labels do |t|
      t.references :local_metadatum, null: false, foreign_key: true
      t.string :cm_local_var_label

      t.timestamps
    end
  end
end
