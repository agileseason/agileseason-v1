class BoardPresenter < Keynote::Presenter
  presents :board

  def name
    raw("#{board.name.try(:gsub, ' ', '&nbsp;')}&nbsp;#{board_type}")
  end

  def last_column?(column)
    column.order == board.columns.map(&:order).max
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
