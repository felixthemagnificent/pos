json.extract! receipt, :id, :total, :created_at, :updated_at
json.url receipt_url(receipt, format: :json)
