class RepoListItem < Renderable
  rattr_initialize :repo, :board

  delegate :id, :full_name, to: :repo

  def url
    repo.html_url
  end

  def icon
    'octicon-repo'
  end

  def can_create_board?
    repo.permissions.admin
  end

  def price
    # NOTE Free
  end

  def enough_permissions?
    board.present? || can_create_board?
  end
end
