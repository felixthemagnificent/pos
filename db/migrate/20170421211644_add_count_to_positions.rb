class AddCountToPositions < ActiveRecord::Migration[5.0]
  def change
    add_column :positions, :count, :integer, default: 0
  end
end
