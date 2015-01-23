class BoardPresenter < Keynote::Presenter
  presents :board

  def name
    raw("#{board.name.try(:gsub, ' ', '&nbsp;')}&nbsp;#{board_type}")
  end

  private

  def board_type
    board.type
      .split('::').last
      .split('Board').first.downcase
  end
end
