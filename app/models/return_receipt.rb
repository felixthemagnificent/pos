class ReturnReceipt < ApplicationRecord
  belongs_to :user
  belongs_to :receipt
  has_many :return_receipt_positions
end
