Rails.application.routes.draw do
  root 'currency_rates#index'
  match '*path', to: 'application#render_404', via: :all
end
