class RepoPresenter < Keynote::Presenter
  presents :repo
  delegate :permissions, :id, to: :repo

  def board
    Board.find_by(github_id: id)
  end
end
