class AddBarcodeToBatch < ActiveRecord::Migration[5.0]
  def change
    add_reference :batches, :barcode, foreign_key: true
  end
end
