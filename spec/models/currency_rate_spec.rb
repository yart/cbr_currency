require 'rails_helper'

RSpec.describe CurrencyRate, type: :model do
  let(:usd)       { 'USD' }
  let(:eur)       { 'EUR' }
  let(:today)     { Date.today }
  let(:yesterday) { Date.yesterday }
  let(:usd_rate)  { CurrencyRate.new(date: today, currency_code: usd, exchange_rate: 1.0) }

  it 'should not save currency rate without date, currency code, and exchange rate' do
    currency_rate = CurrencyRate.new
    expect(currency_rate.save).to be_falsey
  end

  it 'should save valid currency rate' do
    currency_rate = usd_rate
    expect(currency_rate.save).to be_truthy
  end

  it 'should find currency rate by date and currency code' do
    currency_rate = usd_rate
    currency_rate.save

    found_rate = CurrencyRate.find_by(date: today, currency_code: usd)
    expect(found_rate).to eq(currency_rate)
  end

  it 'should not find currency rate with incorrect date or currency code' do
    currency_rate = usd_rate
    currency_rate.save

    incorrect_date_rate = CurrencyRate.find_by(date: yesterday, currency_code: usd)
    incorrect_currency_rate = CurrencyRate.find_by(date: today, currency_code: eur)

    expect(incorrect_date_rate).to     be_nil
    expect(incorrect_currency_rate).to be_nil
  end

  it 'validates presence of date, currency_code, and exchange_rate' do
    currency_rate = CurrencyRate.new

    expect(currency_rate).to_not be_valid
    expect(currency_rate.errors[:date]).to          include("can't be blank")
    expect(currency_rate.errors[:currency_code]).to include("can't be blank")
    expect(currency_rate.errors[:exchange_rate]).to include("can't be blank")
  end
end
