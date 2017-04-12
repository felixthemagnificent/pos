class PrintReceiptJob < ApplicationJob
  queue_as :default

  def perform(receipt_id)
    receipt = Receipt.find(receipt_id)
    lines = []
    lines << "OOO ТЕСТ".center(30, ' ')
    lines << "БУЗ-2, 14".center(30, ' ')
    lines << "Продажа №#{receipt.id}".center(30, ' ')
    lines << ''
    lines << '*'*30
    lines << ''
    receipt.items.each do |item|
      lines << item.name.ljust(24) + item.price.to_s.rjust(6)
    end
    lines << ''
    lines << '*'*30
    lines << 'Итого'.ljust(24) + receipt.total.to_s.rjust(6)
    lines << 'Оплачено'.ljust(24) + receipt.paid.to_s.rjust(6)
    lines << 'Сдача'.ljust(24) + (receipt.paid - receipt.total).to_s.rjust(6)
    lines << 'СПАСИБО ЗА ПОКУПКУ'.center(30, ' ')

    File.open('/tmp/print', 'w') { |file| file.write(lines.join("\n")) }
    system( "lpr -o cpi=16 -o lpi=8 /tmp/print" )
  end
end
