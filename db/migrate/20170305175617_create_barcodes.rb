class CreateBarcodes < ActiveRecord::Migration[5.0]
  def change
    create_table :barcodes do |t|
      t.string :code
      t.references :item, foreign_key: true

      t.timestamps
    end
  end
end
