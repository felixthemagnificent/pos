Rails.application.routes.draw do
  resources :reports, only: :index do
    collection do
      get 'all_receipts'
      get 'mean_receipts'
      get 'total_sum_receipts'
      get 'popular_products'
    end
  end

  get '/items/search', to: 'items#search'
  get '/items/barcode', to: 'items#barcode'
  post '/receipts/close', to: 'receipts#close_receipt'
  resources :receipts
  resources :items do
    resources :barcodes
  end

  root to: 'visitors#index'
  devise_for :users, controllers: { registrations: 'my_devise/registrations' }
  resources :users
end
