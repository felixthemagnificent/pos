class AddReceiptToPosition < ActiveRecord::Migration[5.0]
  def change
    add_reference :positions, :receipt, foreign_key: true
  end
end
