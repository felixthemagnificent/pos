class AddCompanyToItems < ActiveRecord::Migration[5.0]
  def change
    add_reference :items, :company, foreign_key: true
  end
end
