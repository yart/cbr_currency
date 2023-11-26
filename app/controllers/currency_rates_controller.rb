class CurrencyRatesController < ApplicationController
  def index
    @currency_rates = CurrencyRate.all

    @dates     = @currency_rates.pluck(:date).uniq.map { |date| date.strftime("'%Y-%m-%d'") }.join(', ')
    @usd_rates = format_currency_data(@currency_rates, 'USD')
    @eur_rates = format_currency_data(@currency_rates, 'EUR')
  end

  private

  def format_currency_data(currency_rates, currency_code)
    data = currency_rates.where(currency_code: currency_code).pluck(:exchange_rate)
    return 'Something went wrong' unless data.present?

    data.map(&:to_s).join(', ')
  end
end
