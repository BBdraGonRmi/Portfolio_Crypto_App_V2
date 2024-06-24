class Transaction < ApplicationRecord
  belongs_to :user
  belongs_to :wallet

  validates :user_id, presence: true
  validates :wallet_id, presence: true

  validates :datetime_of_transaction, presence: true

  validates :operation, presence: true,
                        length: { minimum: 2, maximum: 10 }

  validates :symbol, presence: true,
                    length: { minimum: 2, maximum: 10 }

  validates :amount, presence: true,
                    numericality: true

  validates :price, presence: true,
                    numericality: true

  validates :net_value, presence: true,
                        numericality: true

  validates :fees, presence: true,
                        numericality: true

  validates :total_value, presence: true,
                          numericality: true
end
