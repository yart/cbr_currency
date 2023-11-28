class CurrencyTableController < ApplicationController
  def index
    week_labels     = ['валюта', '4 недели назад', '3 недели назад', 'позапрошлая неделя', 'прошлая неделя']
    @currency_rates = CurrencyRate.where('date >= ?', start_date).order(:date)
    @grouped_rates  = @currency_rates.group_by(&:currency_code)
    @table_data     = build_currency_table_data(week_labels)
  end

  private

  def start_date
    today      = Date.current
    start_date = today.beginning_of_week

    start_date += 1.day if today.saturday? || today.sunday?

    (start_date - 28.days).beginning_of_week
  end

  def build_currency_table_data(week_labels)
    table_data = { header: week_labels, currencies: [] }

    @grouped_rates.each do |currency_code, rates|
      week_data = [currency_code]

      week_labels[1..-1].each_with_index do |_, index|
        monday_of_week = (index + 1).weeks.ago.to_date.beginning_of_week
        rate_on_monday = rates.find { |rate| rate.date == monday_of_week }

        unless rate_on_monday
          week_data << { rate: 'N/A', growth: 'N/A' }
          next
        end

        week_data << calculate_rate_and_growth(rate_on_monday, rates, index)
      end

      table_data[:currencies] << week_data
    end

    table_data
  end

  def calculate_rate_and_growth(rate_on_monday, rates, week_index)
    friday_of_week = (week_index + 1).weeks.ago.to_date.end_of_week
    rate_on_friday = rates.find { |rate| rate.date == friday_of_week }

    return 'N/A' unless rate_on_friday

    growth_percentage = ((rate_on_friday.exchange_rate - rate_on_monday.exchange_rate) / rate_on_monday.exchange_rate * 100).round(2)
    "#{rate_on_friday.exchange_rate.round(2)} ₽ (#{growth_percentage.positive? ? '+' + growth_percentage.to_s : growth_percentage}%)"
  end
end
