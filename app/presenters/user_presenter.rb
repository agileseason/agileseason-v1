class UserPresenter < Keynote::Presenter
  presents :user
  delegate :github_api, to: :user

  def boards
    (owned_boards + joined_boards).sort_by(&:name)
  end

  def owned_boards
    @owned_boards ||= user.boards.select(&:persisted?)
  end

  def joined_boards
    @joined_boards ||= Board.where(github_name: github_api.cached_repos.map(&:name))
  end
end
