class LocalMetadatumSerializer < ActiveModel::Serializer
  attributes :cm_local_pref_label

  attribute(:cm_local_var_label) { object.local_variants.map(&:cm_local_var_label) }
  attribute(:cm_local_note) { object.local_notes.map(&:cm_local_note) }
end
