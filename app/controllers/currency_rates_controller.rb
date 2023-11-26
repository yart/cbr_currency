class CurrencyRatesController < ApplicationController
  def index
    @currency_rates   = CurrencyRate.all
    @updated_usd_data = format_currency_data(@currency_rates, 'USD')
    @updated_eur_data = format_currency_data(@currency_rates, 'EUR')
  end

  private

  def format_currency_data(currency_rates, currency_code)
    data = currency_rates.where(currency_code: currency_code).pluck(:exchange_rate)
    return 'Found nothing' unless data.present?

    data.map(&:to_s).join(', ')
  end
end
