set :stage, :production

set :server_name, 'agileseason.com'

set :full_app_name, "#{fetch(:application)}_#{fetch(:stage)}"

server 'agileseason.com', user: 'deploy', roles: %w{web app db}, primary: true

set :deploy_user, 'deploy'
set :deploy_to, "/home/#{fetch(:deploy_user)}/apps/#{fetch(:full_app_name)}"
set :rails_env, :production
set :unicorn_worker_count, 2
set :enable_ssl, false

set :sidekiq_processes, 1
set :sidekiq_concurrency, 4
