class LocalMetadatumSerializer < ActiveModel::Serializer
  attributes :cm_local_pref_label

  belongs_to :record
end
