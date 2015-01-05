class RepoPresenter < Keynote::Presenter
  presents :repo
  delegate :permissions, :id, to: :repo

  def board_control?
    permissions.admin
  end

  def board
    Board.find_by(github_id: id)
  end
end
