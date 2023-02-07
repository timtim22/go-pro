Rails.application.routes.draw do

  resources :users
  resources :homes
  post '/auth/login', to: 'authentication#login'
end
