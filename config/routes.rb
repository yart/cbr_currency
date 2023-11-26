Rails.application.routes.draw do
  # get 'currency_rates/index'
  root 'currency_rates#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  match '*path', to: 'application#render_404', via: :all
end
