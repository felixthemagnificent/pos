class AddSupplierPriceToBatch < ActiveRecord::Migration[5.0]
  def change
    add_column :batches, :supplier_price, :integer
  end
end
