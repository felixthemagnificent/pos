class AddReceiptToReturnReceipts < ActiveRecord::Migration[5.0]
  def change
    add_reference :return_receipts, :receipt, foreign_key: true
  end
end
