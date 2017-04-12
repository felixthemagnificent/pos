class Barcode < ApplicationRecord
  belongs_to :item
  validates :count, presence: true
  validates :code, presence: true
  scope :for_user, ->(user) { joins(:item).where(items: { user: user} ) }
end
