class Item < ApplicationRecord
  has_many :positions
  has_many :receipts, through: :positions
  has_many :barcodes, dependent: :destroy
  belongs_to :user
  default_scope { where(is_deleted: false) }

  def self.resolve(current_user)
    if current_user.admin?
      all
    elsif current_user.role.name.eql?('seller')
      where(user: current_user)
    else
      none
    end
  end

  def in_stock
    barcodes.map(&:count).inject(&:+)
  end

  def delete
    update_attribute :is_deleted, true
  end

  def destroy
    update_attribute :is_deleted, true
  end
end
