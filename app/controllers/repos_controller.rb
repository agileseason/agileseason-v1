class ReposController < ApplicationController
  def index
    if repos.blank?
      render(
        plain: "
          You don't have repositories on github.
          Permission level must be the Write or Admin."
      )
    else
      render(
        partial: 'repo',
        collection: repos,
        as: :repo
      )
    end
    ui_event(:board_new, step: 'choose repository', repos: repos.size)
  end

  private

  def repos
    @repos ||= RepoList.new(current_user).menu_repos
  end
end
