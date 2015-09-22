class ReposController < ApplicationController
  def index
    render(
      partial: 'repo',
      collection: RepoList.new(current_user).menu_repos,
      as: :repo
    )
    ui_event(:board_new, step: 'choose repository')
  end
end
