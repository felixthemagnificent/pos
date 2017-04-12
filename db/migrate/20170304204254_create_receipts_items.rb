class CreateReceiptsItems < ActiveRecord::Migration[5.0]
  def change
    create_table :receipts_items, id: false do |t|
      t.belongs_to :receipt, index: true
      t.belongs_to :item, index: true
      t.integer :count
    end
  end
end
