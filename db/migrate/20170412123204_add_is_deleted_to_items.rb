class AddIsDeletedToItems < ActiveRecord::Migration[5.0]
  def change
    add_column :items, :is_deleted, :boolean
  end
end
