class AddLockedAmountToBatches < ActiveRecord::Migration[5.0]
  def change
    add_column :batches, :locked_amount, :integer, default: 0
  end
end
