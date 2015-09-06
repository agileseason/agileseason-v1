class RepoListItem < Renderable
  rattr_initialize :repo, :board

  delegate :id, to: :repo

  def url
    repo.html_url
  end

  def name
    repo.full_name
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
