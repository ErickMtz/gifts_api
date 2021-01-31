Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  # create doorkeeper routes
  use_doorkeeper
  # For details on the DSL available within this file,
  # see https://guides.rubyonrails.org/routing.html
  resources :schools, only: [:create, :update, :destroy] do
    resources :recipients, only: [:index, :create, :update, :destroy]
    resources :orders, only: [:index, :create, :update] do
      post :cancel
      post :ship
    end
  end

  resources :sessions, only: :create
  get 'login', to: 'sessions#new', as: 'login'
  get 'logout', to: 'sessions#destroy', as: 'logout'
  root to: "sessions#current"
end
