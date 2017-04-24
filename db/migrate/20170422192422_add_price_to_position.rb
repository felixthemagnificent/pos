class AddPriceToPosition < ActiveRecord::Migration[5.0]
  def change
    add_column :positions, :price, :integer
  end
end
