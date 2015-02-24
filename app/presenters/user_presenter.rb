class UserPresenter < Keynote::Presenter
  presents :user

  def boards
    user.boards.select(&:persisted?).sort_by(&:name)
  end
end
