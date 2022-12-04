class RecordSerializer < ActiveModel::Serializer

  CentralizedMetadata::Indexer.fields.each do |field_name|
    has_key = -> { object.value.has_key?(field_name) }
    attribute(field_name, if: has_key) { object.value[field_name] }
  end

  attribute :created_at, key: :cm_created_at
  attribute :updated_at, key: :cm_updated_at

  has_one :local_metadatum
end
