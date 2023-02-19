Rails.application.routes.draw do
  resources :users
  resources :videos, only: [:create, :show] do
    post :search_keyword, on: :collection
  end

  post '/auth/login', to: 'authentication#login'
end
