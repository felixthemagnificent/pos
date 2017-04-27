class AddCompanyToReturnReceipts < ActiveRecord::Migration[5.0]
  def change
    add_reference :return_receipts, :company, foreign_key: true
  end
end
