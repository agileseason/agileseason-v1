require 'sidekiq/web'

Rails.application.routes.draw do
  resources :repos, only: [:index]
  resource :docs, only: [] do
    get :cumulative, on: :member
    get :control, on: :member
  end

  resources :boards,
            except: [:edit],
            param: :github_full_name,
            constraints: { github_full_name: /[0-9A-Za-z\-_\.]+(\/|%2F)[0-9A-Za-z\-_\.]+/ } do

    resources :columns do
      member do
        get :move_left
        get :move_right
        patch :update_attribute
      end
    end

    resource :issues, only: [:new, :create] do
      get :search, :collection
      get ':number', to: 'issues#show', as: :show
      get ':number/move_to/:column_id', to: 'issues#move_to', as: :move_to_column
      get ':number/close', to: 'issues#close', as: :close
      get ':number/reopen', to: 'issues#reopen', as: :reopen
      get ':number/archive', to: 'issues#archive', as: :archive
      get ':number/unarchive', to: 'issues#unarchive', as: :unarchive
      get ':number/assignee/:login', to: 'issues#assignee', as: :assignee
      post ':number/due_date', to: 'issues#due_date', as: :due_date
      post ':number/update', to: 'issues#update', as: :update

      get ':number/comments', to: 'comments#index', as: :comments
      post ':number/comment', to: 'comments#create', as: :add_comment
      post ':number/update_comment/:id', to: 'comments#update', as: :update_comment
      delete ':number/delete_comment/:id', to: 'comments#delete', as: :delete_comment
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
      resources :frequency, only: [:index]
      resources :forecast, only: [:index]
    end

    resources :activities, only: [:index]
    post 'preview', to: 'markdown#preview', as: :preview
  end

  mount Sidekiq::Web => '/sidekiq', constraints: SidekiqConstraint.new

  get '/auth/github/callback', to: 'sessions#create'
  get '/sign_out', to: 'sessions#destroy'

  get '/awstest', to: 'awstest#index'

  post 'mixpanel/client_event', to: 'mixpanel#client_event'

  root 'landing#index'
end
