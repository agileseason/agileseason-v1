class ReposController < ApplicationController
  def index
    @repo_list = RepoList.new(current_user)
    render partial: 'repo', collection: @repo_list.menu_repos, as: :repo
  end
end
