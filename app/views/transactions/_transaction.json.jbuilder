json.extract! transaction, :id, :datetime_of_transaction, :operation, :symbol, :amount, :price, :net_value, :fees, :total_value, :user_id, :wallet_id, :created_at, :updated_at
json.url transaction_url(transaction, format: :json)
