class BoardPresenter < Keynote::Presenter
  presents :board
  delegate :name, :type, to: :board

  def name
    raw("#{board.name.try(:gsub, ' ', '&nbsp;')}&nbsp;#{board_type}")
  end

  private

  def board_type
    if board.kanban?
      'kanban'
    elsif board.scrum?
      'scrum'
    end
  end
end
