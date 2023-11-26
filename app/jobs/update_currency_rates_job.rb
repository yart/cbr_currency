class UpdateCurrencyRatesJob < ActiveJob::Base
  # include Sidekiq::Worker
  queue_as :default

  def perform(*)
    CurrencyRateUpdater.update_for_date(Date.today)
  end
end
