class DeleteCountFromBarcodes < ActiveRecord::Migration[5.0]
  def change
    remove_column :barcodes, :count, :integer
  end
end
