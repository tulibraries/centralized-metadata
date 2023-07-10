class LocalMetadatum < ApplicationRecord
  belongs_to :record
  has_many :local_notes
  has_many :local_var_labels
end
