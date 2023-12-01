class ChangeJsonToJsonbInRecords < ActiveRecord::Migration[7.0]
  def change
    change_column :records, :value, :jsonb
  end
end
