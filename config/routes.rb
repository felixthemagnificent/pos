Rails.application.routes.draw do
  resources :companies
  resources :returns, only: [:index, :create]

  resources :batches do
    member do
      get 'journal'
      post 'writeoff'
    end
  end
  TheRoleManagementPanel::Routes.mixin(self)

  resources :reports, only: :index do
    collection do
      get 'all_receipts'
      get 'mean_receipts'
      get 'total_sum_receipts'
      get 'popular_products'
      get 'total_products'
    end
  end

  resources :receipts, only: [:index, :new, :show] do
    collection do
      get 'last_opened'
      post 'close'
      post 'clear'
    end
  end
  resources :items do
    resources :barcodes
    collection do
      post 'addbarcode'
      get 'search'
      get 'process_cheque'
      get 'barcode'
      get 'list'
    end
  end

  root to: 'receipts#new'
  devise_for :users, controllers: { registrations: 'my_devise/registrations' }
  resources :users
end
