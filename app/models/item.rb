class Item < ApplicationRecord
  has_many :receipts_items
  has_many :receipts, through: :receipts_items
  has_many :barcodes, dependent: :destroy
  belongs_to :user
  default_scope { where(is_deleted: false) }

  def in_stock
    barcodes.map(&:count).inject(&:+)
  end

  def delete
    update_attribute :is_deleted, true
  end

  def destroy
    update_attribute :is_deleted, true
  end
end
