class DropTableReceiptsItems < ActiveRecord::Migration[5.0]
  def change
    drop_table :receipts_items
  end
end
