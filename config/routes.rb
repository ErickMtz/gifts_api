Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  # For details on the DSL available within this file,
  # see https://guides.rubyonrails.org/routing.html
  resources :schools, only: [:create, :update, :destroy] do
    resources :recipients, only: [:index, :create, :update, :destroy]
    resources :orders, only: [:index, :create, :update] do
      post :cancel
      post :ship
    end
  end
end
