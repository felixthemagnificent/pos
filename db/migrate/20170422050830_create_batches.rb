class CreateBatches < ActiveRecord::Migration[5.0]
  def change
    create_table :batches do |t|
      t.references :item, foreign_key: true
      t.references :user, foreign_key: true
      t.integer :count

      t.timestamps
    end
  end
end
