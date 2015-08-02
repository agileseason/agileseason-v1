class ReposController < ApplicationController
  def index
    @repos = current_user_repos
    render partial: 'repo', collection: @repos, as: :repo
  end

private
  def current_user_repos
    return [] unless github_token
    #github_api.repos
    github_api.cached_repos
  end
end
