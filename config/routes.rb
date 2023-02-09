Rails.application.routes.draw do
  resources :users
  resources :videos, only: [:create, :show]
  post '/auth/login', to: 'authentication#login'
end
