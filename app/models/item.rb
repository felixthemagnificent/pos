class Item < ApplicationRecord
  has_many :receipts_items
  has_many :receipts, through: :receipts_items
  has_many :barcodes
  belongs_to :user

  def in_stock
    barcodes.map(&:count).inject(&:+)
  end

end
