class Item < ApplicationRecord
  has_many :positions
  has_many :receipts, through: :positions
  has_many :barcodes, dependent: :destroy
  belongs_to :user
  scope :for_user, ->(user) { where(user: user) }
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
