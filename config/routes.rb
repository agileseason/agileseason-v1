Rails.application.routes.draw do

  resources :repos, only: [:index]
  resources :boards, only: [:index, :new, :create, :show] do
    resource :issues, only: [:new, :create] do
      get ':number/move_to/:column_id', to: 'issues#move_to', as: :move_to_column
    end

    namespace :graphs do
      resources :lines, only: [:index]
      resources :cumulative, only: [:index]
    end
  end

  get '/auth/github/callback', to: 'sessions#create'
  get '/sign_out', to: 'sessions#destroy'

  root 'landing#index'

end
