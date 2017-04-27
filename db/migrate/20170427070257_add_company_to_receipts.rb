class AddCompanyToReceipts < ActiveRecord::Migration[5.0]
  def change
    add_reference :receipts, :company, foreign_key: true
  end
end
