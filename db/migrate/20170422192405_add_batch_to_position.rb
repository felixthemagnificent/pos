class AddBatchToPosition < ActiveRecord::Migration[5.0]
  def change
    add_reference :positions, :batch, foreign_key: true
  end
end
