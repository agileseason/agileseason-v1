class RepoList < Renderable
  pattr_initialize :user

  def repos
    @repos ||= user.github_api.repos
  end

  def menu_repos
    repos.map do |repo|
      class_item_by(repo).new(
        repo,
        board_by(repo)
      )
    end.select(&:enough_permissions?)
  end

  private

  def board_by_repos
    @boards ||= Board.where(github_id: repos.map(&:id))
  end

  def board_by(repo)
    board_by_repos.detect { |b| b.github_id == repo.id }
  end

  def class_item_by(repo)
    return RepoListPrivateItem if repo.private
    RepoListItem
  end
end
