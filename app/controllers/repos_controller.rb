class ReposController < ApplicationController
  def index
    @repos = current_user_repos
  end

private
  def current_user_repos
    return [] unless github_token
    api = GithubApi.new(github_token)
    api.repos
  end
end
