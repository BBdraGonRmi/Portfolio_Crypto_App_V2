class Wallet < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true
  validates :name, presence: true,
                    length: { minimum: 2, maximum: 20 }
end
