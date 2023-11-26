require 'rails_helper'

# RSpec.describe CurrencyRate, type: :model do
#   pending "add some examples to (or delete) #{__FILE__}"
# end
RSpec.describe CurrencyRate, type: :model do
  it 'should not save currency rate without date, currency code, and exchange rate' do
    currency_rate = CurrencyRate.new
    expect(currency_rate.save).to be_falsey
  end

  it 'should save valid currency rate' do
    currency_rate = CurrencyRate.new(date: Date.today, currency_code: 'USD', exchange_rate: 1.0)
    expect(currency_rate.save).to be_truthy
  end

  it 'should find currency rate by date and currency code' do
    currency_rate = CurrencyRate.new(date: Date.today, currency_code: 'USD', exchange_rate: 1.0)
    currency_rate.save

    found_rate = CurrencyRate.find_by(date: Date.today, currency_code: 'USD')
    expect(found_rate).to eq(currency_rate)
  end

  it 'should not find currency rate with incorrect date or currency code' do
    currency_rate = CurrencyRate.new(date: Date.today, currency_code: 'USD', exchange_rate: 1.0)
    currency_rate.save

    incorrect_date_rate = CurrencyRate.find_by(date: Date.yesterday, currency_code: 'USD')
    incorrect_currency_rate = CurrencyRate.find_by(date: Date.today, currency_code: 'EUR')

    expect(incorrect_date_rate).to be_nil
    expect(incorrect_currency_rate).to be_nil
  end

  it 'validates presence of date, currency_code, and exchange_rate' do
    currency_rate = CurrencyRate.new

    expect(currency_rate).to_not be_valid
    expect(currency_rate.errors[:date]).to include("can't be blank")
    expect(currency_rate.errors[:currency_code]).to include("can't be blank")
    expect(currency_rate.errors[:exchange_rate]).to include("can't be blank")
  end
end
