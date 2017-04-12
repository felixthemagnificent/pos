class Receipt < ApplicationRecord
  has_many :receipts_items
  has_many :items, through: :receipts_items
  belongs_to :user

  scope :today, -> { where(created_at: DateTime.now.beginning_of_day..DateTime.now.end_of_day) }

  def total
    total_sum = 0
    items.each { |e| total_sum += e.price }
    total_sum
  end

  def self.today_total
    Receipt.today.map(&:total).inject(&:+) || 0
  end

  def getCheque
    lineSize = 30
    strings = []
    company = self.user.company_name
    sell_count = Receipt.all.count
    cur_date_time = DateTime.now.strftime('%d/%m/%Y %H:%M')
    strings << company.center(lineSize, " ")
    strings << "Продажа №" + sell_count.to_s
    strings << cur_date_time.rjust(lineSize)
    strings << '-'*lineSize
    self.items.each do |item|
      product_name = item.name
      product_price = item.price
      if product_name.length + 1 + product_price.to_s.length <= lineSize
        strings << product_name + " "*(lineSize - product_name.length - product_price.to_s.length + 1) + product_price.to_s
      else
        strings << product_name
        strings << product_price
      end
    end
    strings << '-'*lineSize
    strings << "Итого:" + " "*(lineSize - 6 - total.to_s.length) + total.to_s
    strings << "Оплачено:" + " "*(lineSize - 9 - paid.to_s.length) + paid.to_s
    strings << "Сдача:" + " "*(lineSize - 6 - (total-paid).to_s.length) + (total-paid).to_s
    strings << '-'*lineSize
    strings << 'Спасибо за покупку!'.center(lineSize, " ")
    strings.join("\n")
  end
end