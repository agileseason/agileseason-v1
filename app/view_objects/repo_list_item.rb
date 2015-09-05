class RepoListItem
  rattr_initialize :repo, :board

  delegate :id, :full_name, to: :repo

  def url
    repo.html_url
  end

  def icon
    return 'octicon-lock' if private?
    'octicon-repo'
  end

  def can_create_board?
    repo.permissions.admin
  end

  def private?
    repo.private
  end

  def price
    return unless private?
    'Private - $4'
  end

  def enough_permissions?
    board.present? || can_create_board?
  end
end
