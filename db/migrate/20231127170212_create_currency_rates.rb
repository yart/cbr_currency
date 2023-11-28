class CreateCurrencyRates < ActiveRecord::Migration[7.1]
  def change
    create_table :currency_rates do |t|
      t.date :date
      t.string :currency_code
      t.float :exchange_rate

      t.timestamps
    end
  end
end
