class Batch < ApplicationRecord
  belongs_to :barcode
  belongs_to :item
  belongs_to :user
  has_many :positions, dependent: :destroy
  scope :for_user, ->(user) { where(user: user) }
  validates :count, numericality: { only_integer: true, greater_than: 0 }
  validates :price, numericality: { only_integer: true, greater_than: 0 }

end
