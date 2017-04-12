class AddUsersToReceipt < ActiveRecord::Migration[5.0]
  def change
    add_reference :receipts, :user, foreign_key: true
  end
end
