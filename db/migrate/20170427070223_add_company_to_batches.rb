class AddCompanyToBatches < ActiveRecord::Migration[5.0]
  def change
    add_reference :batches, :company, foreign_key: true
  end
end
