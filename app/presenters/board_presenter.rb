class BoardPresenter < Keynote::Presenter
  presents :board

  def name
    raw("#{board.name.try(:gsub, ' ', '&nbsp;')}")
  end

  def last_column?(column)
    column.order == board.columns.map(&:order).max
  end
end
