# FIX Remove this file, move method to the BoardBag.
class BoardPresenter < Keynote::Presenter
  presents :board

  def name
    raw("#{board.name.try(:gsub, ' ', '&nbsp;')}")
  end
end
