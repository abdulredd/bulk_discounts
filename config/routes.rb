Rails.application.routes.draw do
  resources :merchants, only: [:show], module: :merchant do
    resources :dashboard, only: [:index]
    resources :items, except: [:destroy]
    resources :item_status, only: [:update]
    resources :invoices, only: [:index, :show, :update]
    resources :discounts, only: [:index, :show, :new, :create, :destroy, :edit], as: :discounts
  end

  patch "/merchants/:merchant_id/discounts/:id", to: "merchant/discounts#update"

  namespace :admin do
    resources :dashboard, only: [:index]
    resources :merchants, except: [:destroy]
    resources :merchant_status, only: [:update]
    resources :invoices, except: [:new, :destroy]
  end
end
