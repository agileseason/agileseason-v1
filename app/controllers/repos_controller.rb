class ReposController < ApplicationController
  def index
    @repos = current_user_repos
  end

private
  def current_user_repos
    return [] unless session[:github_token]
    client = Octokit::Client.new(access_token: session[:github_token])
    client.repositories
  end
end
