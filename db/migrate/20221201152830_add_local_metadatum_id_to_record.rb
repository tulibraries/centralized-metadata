class AddLocalMetadatumIdToRecord < ActiveRecord::Migration[7.0]
  def change
    add_column :records, :local_metadatum_id, :integer
    add_index :records, :local_metadatum_id
  end
end
