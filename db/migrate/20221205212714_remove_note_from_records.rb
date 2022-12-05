class RemoveNoteFromRecords < ActiveRecord::Migration[7.0]
  def change
    remove_column :records, :note, :string
  end
end
