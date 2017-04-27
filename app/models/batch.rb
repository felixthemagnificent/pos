class Batch < ApplicationRecord
  belongs_to :barcode
  belongs_to :item
  belongs_to :user
  belongs_to :company
  has_many :positions, dependent: :destroy
  scope :for_user, ->(user) { where(user: user) }
  validates :count, numericality: { only_integer: true, greater_than: 0 }
  validates :price, numericality: { only_integer: true, greater_than: 0 }

  def self.resolve(current_user)
    if current_user.admin?
      all
    elsif current_user.company?
      where(company: current_user.company)
    else
      none
    end
  end

end
