class RepoList
  pattr_initialize :user

  def menu_repos
    repos.map do |repo|
      RepoListItem.new(
        repo,
        board_by_repos.detect { |b| b.github_id == repo.id }
      )
    end.select(&:enough_permissions?)
  end

  def repos
    @repos ||= user.github_api.repos
  end

  def board_by_repos
    @boards ||= Board.where(github_id: repos.map(&:id))
  end
end
