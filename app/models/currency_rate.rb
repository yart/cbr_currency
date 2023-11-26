class CurrencyRate < ApplicationRecord
  validates :date, :currency_code, :exchange_rate, presence: true
end
