Rails.application.routes.draw do
  resources :users do
    post :update_user, on: :collection
  end
  resources :videos do
    post :search_keyword, on: :collection
    post :recent, on: :collection
    post :all, on: :collection
    post :transcript, on: :collection
  end

  resources :slices do
    post :cut, on: :collection
  end

  post '/auth/login', to: 'authentication#login'
end
