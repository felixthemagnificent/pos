class Position < ApplicationRecord
  belongs_to :batch
  belongs_to :item
  belongs_to :receipt
  has_many :return_receipt_positions

  validates :count, numericality: { only_integer: true, greater_than: 0 }
  validates :price, numericality: { only_integer: true, greater_than: 0 }
end
