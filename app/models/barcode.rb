class Barcode < ApplicationRecord
  belongs_to :item
  validates :code, presence: true, numericality: { only_integer: true, greater_than: 0 }
  has_many :batches
end
