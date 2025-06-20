Rails.application.routes.draw do
  get 'home/index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  root "home#index"

  namespace :api do
    get 'students/search', to: 'students#search'
    get "students/export", to: "students#export", defaults: { format: :csv }
  end

  namespace :api do
    get 'filters', to: 'filters#index'
  end


  get '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/failure', to: redirect('/')

  get "/login", to: "login#index"
  get "/logout", to: "sessions#destroy" , as: :logout
  #get '/login', to: 'sessions#new', as: :login
  #delete '/logout', to: 'sessions#destroy', as: :logout

end

