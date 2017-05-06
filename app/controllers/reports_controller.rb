class ReportsController < ApplicationController
  before_action :role_required
  def index
  end

  def all_receipts
    receipts = Receipt.resolve(current_user).where.not(status: :opened)
    grid_data = []
    types = {
      created_at: 'datetime',
      price: 'string'
    }
    receipts, total = KendoFilter.filter_grid(params, receipts, types)

    receipts.each do |receipt|
      grid_data.push({
        id: receipt.id,
        created_at: receipt.created_at.strftime("%m/%d/%Y %I:%M %p"),
        income: receipt.total,
        profit: receipt.positions.map { |e| (e.item.have_weight ? e.count / 1000 : e.count) * (e.batch.price - e.batch.supplier_price) } .inject(&:+)

      })
    end
    render json: {data: grid_data, total: total}
  end

  def total_products
    item_ids = Batch.resolve(current_user).select(:item_id).distinct.map(&:item_id)
    items = Item.where(id: item_ids).map { |e|
      {
        name: e.name,
        item_id: e.id,
        batch_count: Batch.where(item_id: e.id).count,
        last_added: Batch.where(item_id: e.id).try(:last).try(:created_at),
        price: Batch.where(item_id: e.id).where.not(count: 0).try(:first).try(:price),
        amount: Batch.where(item_id: e.id).map(&:count).inject(&:+)
      }
    }

    render json: items
  end

  def mean_receipts
    grid_data = []
    types = {
      created_at: 'datetime',
      price: 'string'
    }
    all_closed_receipts = Receipt.resolve(current_user).where.not(status: :opened)

    receipts, total = KendoFilter.filter_grid(params, all_closed_receipts, types)

    dates = receipts.pluck(:created_at).map(&:to_date).uniq
    dates.each do |date|
      total_cheques_per_day = all_closed_receipts.where(created_at: date.beginning_of_day..date.end_of_day).map(&:total)
      average_day_income = total_cheques_per_day.inject(&:+)/total_cheques_per_day.count
      grid_data << { created_at: date, price: average_day_income, count: total_cheques_per_day.count }
    end

    render json: {data: grid_data, total: dates.size}
  end

  def total_sum_receipts
    grid_data = []
    types = {
      created_at: 'datetime',
      price: 'string'
    }
    all_closed_receipts = Receipt.resolve(current_user).where.not(status: :opened)
    receipts, total = KendoFilter.filter_grid(params, all_closed_receipts, types)

    dates = receipts.pluck(:created_at).map(&:to_date).uniq
    dates.each do |date|
      total_cheques_per_day = all_closed_receipts.where(created_at: date.beginning_of_day..date.end_of_day).map(&:total)
      total_day_income = total_cheques_per_day.inject(&:+)
      grid_data << { created_at: date, price: total_day_income, count: total_cheques_per_day.count }
    end

    render json: {data: grid_data, total: dates.size}
  end
  def popular_products
    grid_data = []
    types = {
      created_at: 'datetime',
      price: 'string'
    }
    items = Position.joins(:receipt).where(receipts: {user: User.second}).map(&:item).map(&:id).uniq.map { |e| Item.find(e) }
    products = items.map do |e|
      {
        name: e.name,
        price: Batch.resolve(current_user).where(item: e).first.price,
        receipts: Position.where(item: e).count
      }
    end
    products = products.sort_by { |e| e['receipts']  }
    products.each_with_index do |product, index|
      grid_data << { product: product[:name], place: index+1, count: product[:receipts], selled: product[:receipts]*product[:price]  }
    end

    render json: {data: grid_data, total: products.size}
  end
end
