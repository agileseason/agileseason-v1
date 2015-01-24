Rails.application.routes.draw do
  resources :repos, only: [:index]
  resources :boards,
            except: [:edit],
            param: :github_name,
            constraints: { github_name: /[0-9A-Za-z\-_\.]+/ } do

    resource :issues, only: [:new, :create, :show] do
      get ':number/move_to/:column_id', to: 'issues#move_to', as: :move_to_column
      get ':number/close', to: 'issues#close', as: :close
      get ':number/archive', to: 'issues#archive', as: :archive
      get ':number/assignee', to: 'issues#assignee', as: :assignee
      get ':number/show', to: 'issues#show', as: :show
      get ':number/update', to: 'issues#update', as: :update
    end

    resource :settings, only: [:show, :update] do
      member do
        patch :rename
      end
    end

    namespace :graphs do
      resources :lines, only: [:index]
      resources :cumulative, only: [:index]
      resources :control, only: [:index]
      resources :duration, only: [:index]
    end
  end

  get '/auth/github/callback', to: 'sessions#create'
  get '/sign_out', to: 'sessions#destroy'

  root 'landing#index'
end
