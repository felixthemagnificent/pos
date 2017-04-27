class ReturnReceipt < ApplicationRecord
  belongs_to :user
  belongs_to :receipt
  belongs_to :company
  has_many :return_receipt_positions

  def getCheque
    lineSize = 26
    strings = []
    company = self.user.company.name
    cur_date_time = DateTime.now.strftime('%d/%m/%Y %H:%M')
    strings << company.center(lineSize, " ") if company
    strings << "Возвратный чек"
    strings << cur_date_time
    strings << '*'*lineSize
    self.return_receipt_positions.where.not(amount: 0).each do |rrp|
      product_name = rrp.position.batch.item.name
      product_price = rrp.position.batch.price
      if product_name.length + 1 + product_price.to_s.length <= lineSize
        strings << product_name.ljust(lineSize - product_price.to_s.length) + product_price.to_s
      else
        strings << product_name
        strings << product_price
      end
    end
    strings << '*'*lineSize
    strings << 'Спасибо за доверие!'
    strings.join("\n")
  end
end
