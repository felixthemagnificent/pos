class Batch < ApplicationRecord
  belongs_to :barcode
  belongs_to :item
  belongs_to :user
  scope :for_user, ->(user) { where(user: user) }
end
