require 'rails_helper'

RSpec.describe "CurrencyTables", type: :request do
  describe "GET /currency_table" do
    it "returns http success" do
      get "/currency_table"
      expect(response).to have_http_status(:success)
    end
  end

end
