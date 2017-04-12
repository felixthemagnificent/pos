Rails.application.routes.draw do
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
