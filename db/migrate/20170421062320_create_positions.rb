class CreatePositions < ActiveRecord::Migration[5.0]
  def change
    create_table :positions do |t|
      t.references :barcode, foreign_key: true
      t.references :item, foreign_key: true
      t.timestamps
    end
  end
end
