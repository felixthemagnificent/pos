class Barcode < ApplicationRecord
  belongs_to :item
  validates :code, presence: true, uniqueness: true
  has_many :batches
end
