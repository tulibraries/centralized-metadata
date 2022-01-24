class CreateRecords < ActiveRecord::Migration[7.0]
  def change
    create_table :records do |t|
      t.string :identifier
      t.string :pref_label
      t.string :var_label
      t.string :local_pref_label
      t.string :local_var_label
      t.string :source_vocab
      t.string :import_method
      t.string :type
      t.string :see_also
      t.string :skos_exact_match
      t.string :skos_close_match
      t.string :lc_class
      t.string :local_note

      t.timestamps
    end
    add_index :records, :identifier, unique: true
  end
end
