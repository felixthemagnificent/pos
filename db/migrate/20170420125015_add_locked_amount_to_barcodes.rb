class AddLockedAmountToBarcodes < ActiveRecord::Migration[5.0]
  def change
    add_column :barcodes, :locked_amount, :integer, null: false, default: 0
  end
end
