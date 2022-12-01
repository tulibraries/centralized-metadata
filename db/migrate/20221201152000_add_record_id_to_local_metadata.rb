class AddRecordIdToLocalMetadata < ActiveRecord::Migration[7.0]
  def change
    add_column :local_metadata, :record_id, :string
    add_index :local_metadata, :record_id
  end
end
