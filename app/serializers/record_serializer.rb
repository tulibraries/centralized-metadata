class RecordSerializer < ActiveModel::Serializer
  attributes :value

  has_one :local_metadatum
end
