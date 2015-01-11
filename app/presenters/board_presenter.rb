class BoardPresenter < Keynote::Presenter
  presents :board

  def board_name
    board.type
      .split('::').last
      .split('Board').first.downcase
  end
end
