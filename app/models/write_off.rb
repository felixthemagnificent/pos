class WriteOff < ApplicationRecord
  belongs_to :batch
  belongs_to :item

  enum reason: [:lost_attraction, :operator_error, :move_another_store, :return_to_supplier]
  def self.category_names
    {
      lost_attraction: "Потерял товарный вид",
      operator_error: "Ошибка оператора",
      move_another_store: "Перемещение в другой магазин",
      return_to_supplier: "Возврат поставщику"
    }
  end
end
