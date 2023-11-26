class CurrencyRate < ApplicationRecord
  validates :date, :currency_code, :exchange_rate, presence: true

  def self.updated_data(currency_code)
    # Логика для получения обновленных данных
    # Возвращаем массив значений курса валюты для данного currency_code
    where(currency_code: currency_code).pluck(:exchange_rate)
  end
end
