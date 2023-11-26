FactoryBot.define do
  factory :currency_rate do
    date { Date.today }
    currency_code { 'USD' }
    exchange_rate { 1.0 }
  end
end
