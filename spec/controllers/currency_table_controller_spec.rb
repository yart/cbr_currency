require 'rails_helper'

RSpec.describe CurrencyTableController, type: :controller do
  describe 'GET #index' do
    it 'renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end

    it 'assigns @table_data' do
      VCR.use_cassette('currency_rates') do
        get :index
      end
      expect(assigns(:table_data)).to be_a(Hash)
    end
  end
end
