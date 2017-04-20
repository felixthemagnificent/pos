class Barcode < ApplicationRecord
  belongs_to :item
  validates :count, presence: true
  validates :code, presence: true
  scope :for_user, ->(user) { joins(:item).where(items: { user: user} ) }

  def in_stock
    self.count > 0
  end
end
