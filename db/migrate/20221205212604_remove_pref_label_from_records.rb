class RemovePrefLabelFromRecords < ActiveRecord::Migration[7.0]
  def change
    remove_column :records, :pref_label, :string
  end
end
