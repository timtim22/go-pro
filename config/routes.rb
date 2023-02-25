Rails.application.routes.draw do
  resources :users
  resources :videos do
    post :search_keyword, on: :collection
    get :recent_vidoes, on: :collection
  end

  post '/auth/login', to: 'authentication#login'
end
