class Position < ApplicationRecord
  belongs_to :barcode
  belongs_to :item
  belongs_to :receipt
end
