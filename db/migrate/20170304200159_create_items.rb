class CreateItems < ActiveRecord::Migration[5.0]
  def change
    create_table :items do |t|
      t.string :sku
      t.string :name
      t.string :in_stock
      t.integer :price

      t.timestamps
    end
  end
end
