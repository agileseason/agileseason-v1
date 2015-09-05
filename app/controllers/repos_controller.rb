class ReposController < ApplicationController
  def index
    render(
      partial: 'repo',
      collection: RepoList.new(current_user).menu_repos,
      as: :repo
    )
  end
end
