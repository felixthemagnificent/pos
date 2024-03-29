class Receipt < ApplicationRecord
  has_many :positions, dependent: :destroy
  has_many :items, through: :positions
  belongs_to :user
  belongs_to :company
  before_save :update_total
  scope :for_user, ->(user) { where(user: user) }
  scope :today, -> { where(created_at: DateTime.now.beginning_of_day..DateTime.now.end_of_day) }
  enum status: [:opened, :closed]

  def self.resolve(current_user)
    if current_user.admin?
      all
    elsif current_user.company?
      where(company: current_user.company)
    else
      none
    end
  end

  def update_total
    total_sum = 0
    positions.each do |p|
      temp_sum = Batch.for_user(user).where(item: p.item).first.price * p.count
      total_sum += p.item.have_weight ? temp_sum / 1000 : temp_sum
    end
    self.total = total_sum
  end

  def self.today_total
    Receipt.today.map(&:total).inject(&:+) || 0
  end

  def self.last_opened
    where(status: :opened).last
  end

  def getCheque(current_user)
    lineSize = 26
    strings = []
    company = self.user.company.name
    sell_count = Receipt.for_user(self.user).where(status: :closed).last.id
    cur_date_time = DateTime.now.strftime('%d/%m/%Y %H:%M')
    strings << company.center(lineSize, " ") if company
    strings << "Продажа №" + sell_count.to_s
    strings << cur_date_time
    strings << '*'*lineSize
    self.positions.each do |position|
      product_name = position.item.name
      product_price = position.batch.price
      if product_name.length + 1 + product_price.to_s.length <= lineSize
        strings << product_name.ljust(lineSize - product_price.to_s.length) + product_price.to_s
      else
        strings << product_name
        strings << product_price
      end
    end
    strings << '*'*lineSize
    strings << "Итого:".ljust(lineSize - total.to_s.length) + total.to_s
    strings << "Оплачено:".ljust(lineSize - paid.to_s.length) + paid.to_s
    strings << "Сдача:".ljust(lineSize - (total-paid).to_s.length) + (total-paid).to_s
    strings << '*'*lineSize
    strings << 'Спасибо за покупку!'
    strings.join("\n")
  end
end
