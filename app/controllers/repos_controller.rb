class ReposController < ApplicationController
  def index
    @repos = current_user_repos
  end

private
  def current_user_repos
    return [] unless github_token
    github_api.repos
  end
end
