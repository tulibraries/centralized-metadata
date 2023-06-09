class Record < ApplicationRecord
  has_one :local_metadatum
  accepts_nested_attributes_for :local_metadatum
end
