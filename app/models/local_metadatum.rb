class LocalMetadatum < ApplicationRecord
  belongs_to :record
  has_many :local_notes
  has_many :local_variants
end
