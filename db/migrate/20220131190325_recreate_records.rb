class RecreateRecords < ActiveRecord::Migration[7.0]
  def change
    create_table :records, id: :string, force: true do |t|
      t.json :value, default: {}

      # Local overrides for the same key in the value json object.
      # We could move these to their own table but there are pros/cons that should be consiered.
      t.string :pref_label
      t.string :var_label
      t.string :note

      t.timestamps
    end
  end
end
