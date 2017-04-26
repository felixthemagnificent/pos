class CreateWriteOffs < ActiveRecord::Migration[5.0]
  def change
    create_table :write_offs do |t|
      t.references :batch, foreign_key: true
      t.references :item, foreign_key: true
      t.integer :amount
      t.integer :reason

      t.timestamps
    end
  end
end
