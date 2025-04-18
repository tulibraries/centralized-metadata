# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2025_03_28_192730) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "local_metadata", force: :cascade do |t|
    t.string "cm_local_pref_label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "record_id"
    t.index ["cm_local_pref_label"], name: "index_local_metadata_on_cm_local_pref_label"
    t.index ["record_id"], name: "index_local_metadata_on_record_id"
  end

  create_table "local_notes", force: :cascade do |t|
    t.bigint "local_metadatum_id", null: false
    t.string "cm_local_note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["local_metadatum_id"], name: "index_local_notes_on_local_metadatum_id"
  end

  create_table "local_var_labels", force: :cascade do |t|
    t.bigint "local_metadatum_id", null: false
    t.string "cm_local_var_label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["local_metadatum_id"], name: "index_local_var_labels_on_local_metadatum_id"
  end

  create_table "records", id: :string, force: :cascade do |t|
    t.jsonb "value", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "local_notes", "local_metadata"
  add_foreign_key "local_var_labels", "local_metadata"
end
