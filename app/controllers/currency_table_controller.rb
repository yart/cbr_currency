class CurrencyTableController < ApplicationController
  def index
    # Looks like better is to move these literals to i18n…
    @week_labels    = ['валюта', '4 недели назад', '3 недели назад', 'позапрошлая неделя', 'прошлая неделя']
    @start_date     = Date.current.beginning_of_week - 4.weeks
    @currency_rates = CurrencyRate.where('date >= ?', @start_date).order(:date)
    @grouped_rates  = @currency_rates.group_by(&:currency_code)
    @table_data     = build_currency_table_data
  end

  private

  def build_currency_table_data
    table_data = { header: @week_labels, currencies: [] }

    @grouped_rates.each do |currency_code, rates|
      week_data = [currency_code]

      # To skip the currency column. Maybe better to use 4.times here, but I hope the current way is 
      # more clearly to understand what is happening here.
      @week_labels[1..-1].each_with_index do |_, index|
        monday_of_week = @start_date.since(index.weeks)
        rate_on_monday = find_rate(rates, monday_of_week)

        unless rate_on_monday
          week_data << 'N/A'
          next
        end

        week_data << calculate_rate_and_growth(rates, rate_on_monday, monday_of_week)
      end

      table_data[:currencies] << week_data
    end

    table_data
  end

  def calculate_rate_and_growth(rates, rate_on_monday, date_on_monday)
    # ATTENTION: CBR doesn't change any currency rate during weekend, so we can use friday as the end of any week
    friday_of_week = date_on_monday + 4.days
    rate_on_friday = find_rate(rates, friday_of_week)

    return 'N/A' unless rate_on_friday

    mondays_rate      = rate_on_monday.exchange_rate
    fridays_rate      = rate_on_friday.exchange_rate
    growth_percentage = ((fridays_rate - mondays_rate) / mondays_rate * 100).round(2)
    formatted_growth  = (growth_percentage.positive? ? '+' + growth_percentage.to_s : growth_percentage.to_s) + '%'

    "#{rate_on_monday.exchange_rate.round(2)} ₽ (#{formatted_growth})"
  end

  def find_rate(rates, day)
    rates.find { |rate| rate.date == day }
  end
end
