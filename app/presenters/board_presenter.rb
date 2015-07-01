class BoardPresenter < Keynote::Presenter
  presents :board

  def name
    raw("#{board.name.try(:gsub, ' ', '&nbsp;')}")
  end
end
