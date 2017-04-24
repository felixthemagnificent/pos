class RemoveSkuFromItem < ActiveRecord::Migration[5.0]
  def change
    remove_column :items, :sku, :integer
  end
end
