require 'rails_helper'

RSpec.describe CurrencyRateUpdater, type: :service, vcr: true do
  let(:usd) { 'USD' }
  let(:eur) { 'EUR' }
  let(:some_date)  { Date.new(2023, 2, 8) }
  let(:other_date) { Date.new(2023, 2, 9) }
  let(:url) { "https://www.cbr.ru/scripts/XML_daily.asp?date_req=#{some_date.strftime('%d/%m/%Y')}" }

  describe '.form_url' do
    it 'forms the correct URL' do
      expected_url = url
      actual_url   = CurrencyRateUpdater.form_url(some_date)

      expect(actual_url).to eq(expected_url)
    end
  end

  describe '.fetch_xml_data' do
    it 'handles unsuccessful HTTP response' do
      allow(Net::HTTP).to receive(:get_response).and_return(Net::HTTPNotFound.new('1.1', '404', 'Not Found'))

      result = CurrencyRateUpdater.fetch_xml_data(url)

      expect(result).to be_nil
    end
  end

  describe '.update_for_date' do
    it 'should update currency rates for the given date' do
      VCR.use_cassette('currency_rates') do
        CurrencyRateUpdater.update_for_date(other_date)

        usd_rate = CurrencyRate.find_by_date_and_currency_code(other_date, usd)
        eur_rate = CurrencyRate.find_by_date_and_currency_code(other_date, eur)

        expect(usd_rate).not_to be_nil
        expect(eur_rate).not_to be_nil
      end
    end

    it 'handles XML parsing errors' do
      allow(CurrencyRateUpdater).to receive(:fetch_xml_data) { '<invalid_xml>' }

      result = CurrencyRateUpdater.update_for_date(some_date)

      expect(result).to be_nil
    end

    it 'updates the record only if the exchange rate has changed' do
      currency_code = usd
      existing_exchange_rate = 71.5763
      new_exchange_rate = 72.1234

      existing_record = create(
        :currency_rate,
        date: some_date,
        currency_code: currency_code,
        exchange_rate: existing_exchange_rate
      )

      allow(CurrencyRate).to receive(:find_or_initialize_by).and_return(existing_record)

      CurrencyRateUpdater.update_or_create_currency_rate(some_date, currency_code, new_exchange_rate)

      expect(existing_record.reload.exchange_rate).to eq(new_exchange_rate)
    end
  end
end
