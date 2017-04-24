class RemoveLockedAmountFromBarcode < ActiveRecord::Migration[5.0]
  def change
    remove_column :barcodes, :locked_amount, :integer
  end
end
