start_date = 1.month.ago.to_date
end_date = Date.today

(start_date..end_date).each do |date|
  CurrencyRateUpdater.update_for_date(date)
end
