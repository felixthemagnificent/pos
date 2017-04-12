class AddPaidToReceipt < ActiveRecord::Migration[5.0]
  def change
    add_column :receipts, :paid, :integer
  end
end
