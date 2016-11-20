require 'sidekiq/web'

Rails.application.routes.draw do
  resources :repos, only: [:index]
  resource :docs, only: [] do
    member do
      get :main
      get :board_features
      get :cumulative
      get :control
      get :age
    end
  end

  resource :preferences, only: [:update]

  resources :boards,
            except: [:edit],
            param: :github_full_name,
            constraints: { github_full_name: /[0-9A-Za-z\-_\.]+(\/|%2F)[0-9A-Za-z\-_\.]+/ } do

    resources :columns do
      member do
        get :move_left
        get :move_right
        patch :update_attribute
        get :settings
      end
    end

    namespace :board_issues do
      resource :search, only: [:show]
    end

    resource :issues, only: [:new, :create] do
      get ':number', to: 'issues#show', as: :show
      get ':number/modal_data', to: 'board_issues/modals#show', as: :modal_data

      get ':number/miniature', to: 'board_issues/miniatures#show', as: :miniature
      post ':number/toggle_ready', to: 'issues#toggle_ready', as: :toggle_ready

      patch ':number/update', to: 'issues#update', as: :update
      patch ':number/labels', to: 'board_issues/labels#update', as: :update_labels
      patch ':number/colors', to: 'board_issues/colors#update', as: :update_color
      patch ':number/states', to: 'board_issues/states#update', as: :update_state
      patch ':number/assignee/:login', to: 'board_issues/assignees#update', as: :assignee
      patch ':number/due_date', to: 'board_issues/due_dates#update', as: :due_date
      patch ':number/moves/:column_id(/:force)', to: 'board_issues/moves#update', as: :move_to_column

      get ':number/comments', to: 'comments#index', as: :comments
      post ':number/comment', to: 'comments#create', as: :add_comment
      post ':number/update_comment/:id', to: 'comments#update', as: :update_comment
      delete ':number/delete_comment/:id', to: 'comments#delete', as: :delete_comment
    end

    resource :settings, only: [:show, :update] do
      member do
        patch :rename
        get :apply_hook
        delete :remove_hook
      end
    end

    namespace :graphs do
      resources :cumulative, only: [:index]
      resources :control, only: [:index]
      resources :frequency, only: [:index]
      resources :age, only: [:index]
      resources :lines, only: [:index]
    end

    resource :subscriptions, only: [:new] do
      get :early_access
    end

    resources :activities, only: [:index]
    resources :issue_stats, only: :update
    resource :exports, only: [:show]

    post 'preview', to: 'markdown#preview', as: :preview
  end

  mount Sidekiq::Web => '/sidekiq', constraints: SidekiqConstraint.new

  get '/auth/github/callback', to: 'sessions#create'
  get '/sign_out', to: 'sessions#destroy'

  get '/awstest', to: 'awstest#index'
  get '/demo', to: 'landing#demo', as: :demo
  get '/mixpanel_events/client_event', to: 'mixpanel_events#client_event'
  post '/webhooks/github'

  root 'landing#index'
end
