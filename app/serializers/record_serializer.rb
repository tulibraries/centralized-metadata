class RecordSerializer < ActiveModel::Serializer
  attributes :value
  has_one :local_metadatum

  def value
    object.value.merge(cm_date_metadata)
  end


  private

  def cm_date_metadata
    { "cm_created_at" => object.created_at,
      "cm_updated_at" => object.updated_at }
  end
end
