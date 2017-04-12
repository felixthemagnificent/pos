json.extract! item, :id, :sku, :name, :in_stock, :price, :created_at, :updated_at
json.url item_url(item, format: :json)
