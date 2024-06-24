class Transaction < ApplicationRecord
  belongs_to :user
  belongs_to :wallet

  before_validation :set_fees_and_total_value
  before_save { self.symbol.upcase! }

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

  private

    def set_fees_and_total_value
      if !self.fees.present?
        self.fees = 0
        if !self.total_value.present?
          self.total_value = self.net_value
        end
      end
    end
end
