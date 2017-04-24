class Position < ApplicationRecord
  belongs_to :batch
  belongs_to :item
  belongs_to :receipt
end
