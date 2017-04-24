class RemoveBarcodeFromPosition < ActiveRecord::Migration[5.0]
  def change
    remove_reference :positions, :barcode, foreign_key: true
  end
end
