class AddCountToBarcodes < ActiveRecord::Migration[5.0]
  def change
    add_column :barcodes, :count, :integer
  end
end
