class RemoveVarLabelFromRecords < ActiveRecord::Migration[7.0]
  def change
    remove_column :records, :var_label, :string
  end
end
