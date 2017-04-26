class CreateReturnReceiptPositions < ActiveRecord::Migration[5.0]
  def change
    create_table :return_receipt_positions do |t|
      t.references :position, foreign_key: true
      t.integer :amount
      t.references :return_receipt, foreign_key: true

      t.timestamps
    end
  end
end
