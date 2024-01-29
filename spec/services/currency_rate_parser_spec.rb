require 'rails_helper'

RSpec.describe CurrencyRateParser, type: :service do
  let(:usd) { 'USD' }
  let(:eur) { 'EUR' }
  let(:some_date)  { Date.new(2023, 2, 8) }
  let(:other_date) { Date.new(2023, 2, 9) }
  let(:parser) { CurrencyRateParser.new(some_date) }
  let(:url) { format(Rails.application.config.cbr_currency_settings['api'], date: some_date.strftime('%d/%m/%Y')) }

  describe '#initialize' do
    it 'should initialize with a date' do
      expect(parser.instance_variable_get(:@date)).to eq(some_date)
    end
  end

  describe '#form_url' do
    it 'should return a formatted URL' do
      allow(Rails.application.config.cbr_currency_settings).to receive(:[]).with('api').and_return('http://example.com/?date=%<date>s')

      expected_date = some_date.strftime('%d/%m/%Y')
      example_url   = parser.send(:form_url)

      expect(example_url).to eq("http://example.com/?date=#{expected_date}")
    end
  end

  describe '#fetch_xml_data' do
    context 'when the request is successful' do
      it 'should return Nokogiri::XML object' do
        allow(Net::HTTP).to receive(:get_response).and_return(double(Net::HTTPSuccess, body: '<xml>data</xml>'))

        xml_data = parser.fetch_xml_data

        expect(xml_data).to be_a(Nokogiri::XML::Document)
      end
    end

    it 'handles unsuccessful HTTP response' do
      allow(Net::HTTP).to receive(:get_response).and_return(Net::HTTPNotFound.new('1.1', '404', 'Not Found'))

      result = parser.fetch_xml_data

      expect(result).to be_nil
    end
  end
end
