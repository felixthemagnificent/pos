class CreateReceiptsPositions < ActiveRecord::Migration[5.0]
  def change
    create_table :receipts_positions, id: false do |t|
      t.belongs_to :receipt, index: true
      t.belongs_to :position, index: true
      t.integer :count
    end
  end
end
