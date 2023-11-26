require 'rails_helper'

RSpec.describe CurrencyRateUpdater, type: :service, vcr: true do
  describe '.update_for_date' do
    it 'should update currency rates for the given date' do
      VCR.use_cassette('currency_rates') do
        date = Date.new(2023, 2, 9)
        CurrencyRateUpdater.update_for_date(date)

        usd_rate = CurrencyRate.find_by_date_and_currency_code(date, 'USD')
        eur_rate = CurrencyRate.find_by_date_and_currency_code(date, 'EUR')

        expect(usd_rate).not_to be_nil
        expect(eur_rate).not_to be_nil
      end
    end

    it 'handles unsuccessful HTTP response' do
      date = Date.new(2023, 2, 10)
      url = "https://www.cbr.ru/scripts/XML_daily.asp?date_req=#{date.strftime('%d/%m/%Y')}"

      allow(Net::HTTP).to receive(:get_response).and_return(Net::HTTPNotFound.new('1.1', '404', 'Not Found'))

      expect(Rails.logger).to receive(:error).with("Failed to fetch data from #{url}: HTTP error 404")

      CurrencyRateUpdater.update_for_date(date)
    end

    it 'handles XML parsing errors' do
      date = Date.new(2023, 2, 10)
      url = "https://www.cbr.ru/scripts/XML_daily.asp?date_req=#{date.strftime('%d/%m/%Y')}"

      allow(CurrencyRateUpdater).to receive(:fetch_xml_data) { '<invalid_xml>' }
      CurrencyRateUpdater.update_for_date(date)

      expect(CurrencyRateUpdater.update_for_date(date)).to be_nil
    end

    it 'forms the correct URL' do
      date = Date.new(2023, 2, 10)
      expected_url = "https://www.cbr.ru/scripts/XML_daily.asp?date_req=#{date.strftime('%d/%m/%Y')}"

      allow(Rails.logger).to receive(:info)
      actual_url = CurrencyRateUpdater.form_url(date)

      expect(actual_url).to eq(expected_url)
    end

    it 'updates the record only if the exchange rate has changed' do
      date = Date.new(2023, 2, 10)
      currency_code = 'USD'
      existing_exchange_rate = 71.5763
      new_exchange_rate = 72.1234

      existing_record = create(
        :currency_rate,
        date: date,
        currency_code: currency_code,
        exchange_rate: existing_exchange_rate
      )

      allow(CurrencyRate).to receive(:find_or_initialize_by).and_return(existing_record)
      CurrencyRateUpdater.update_or_create_currency_rate(date, currency_code, new_exchange_rate)
      expect(existing_record.reload.exchange_rate).to eq(new_exchange_rate)
    end
  end
end
