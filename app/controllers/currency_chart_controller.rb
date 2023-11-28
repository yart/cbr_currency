class CurrencyChartController < ApplicationController
  def index
    start_date = 1.month.ago.to_date

    @currency_rates = CurrencyRate.where('date >= ?', start_date).order(:date)

    @dates     = @currency_rates.pluck(:date).uniq.map { |date| date.strftime("'%Y-%m-%d'") }.join(', ')
    @usd_rates = format_currency_data('USD')
    @eur_rates = format_currency_data('EUR')
    @cny_rates = format_currency_data('CNY')
  end

  private

  def format_currency_data(currency_code)
    data = @currency_rates.where(currency_code:).pluck(:exchange_rate)
    return 'Something went wrong' unless data.present?

    data.map(&:to_s).join(', ')
  end
end
