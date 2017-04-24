class AddPriceToBatch < ActiveRecord::Migration[5.0]
  def change
    add_column :batches, :price, :integer
  end
end
