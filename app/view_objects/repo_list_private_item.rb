class RepoListPrivateItem < RepoListItem
  rattr_initialize :repo, :board

  def icon
    'octicon-lock'
  end

  def price
    'Private - $4'
  end
end
