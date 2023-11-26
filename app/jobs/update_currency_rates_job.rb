class UpdateCurrencyRatesJob < ActiveJob::Base
  queue_as :default

  def perform(*)
    CurrencyRateUpdater.update_for_date(Date.today)
  end
end
