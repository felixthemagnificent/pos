class AddHaveWeightToItem < ActiveRecord::Migration[5.0]
  def change
    add_column :items, :have_weight, :boolean
  end
end
