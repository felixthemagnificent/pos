class RemoveInStockFromItems < ActiveRecord::Migration[5.0]
  def change
    remove_column :items, :in_stock, :string
  end
end
