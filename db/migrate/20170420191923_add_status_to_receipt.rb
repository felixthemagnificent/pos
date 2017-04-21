class AddStatusToReceipt < ActiveRecord::Migration[5.0]
  def change
    add_column :receipts, :status, :integer
    Receipt.all do |receipt|
      receipt.closed!
    end
  end
end
