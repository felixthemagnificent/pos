class ReturnReceiptPosition < ApplicationRecord
  belongs_to :position
  belongs_to :return_receipt
end
