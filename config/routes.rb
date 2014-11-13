Rails.application.routes.draw do

  resources :repos, only: [:index]
  resources :boards, only: [:index, :new, :create]

  get '/auth/github/callback', to: 'sessions#create'
  get '/sign_out', to: 'sessions#destroy'

  root 'landing#index'

end
