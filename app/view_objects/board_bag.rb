class BoardBag
  pattr_initialize :github_api, :board, :is_readonly
  delegate :github_name, :columns, :to_param, to: :board

  def collaborators
    @collaborators ||= cached_collaborators
  end

  def issues
    @issues ||= @github_api.board_issues(@board)
  end

  def labels
    @labels ||= cached_labels
  end

  def build_issue_new
    Issue.new(labels: labels.map(&:name))
  end

  private

  def cache_key(posfix)
    ["board_bag_#{board.id}", posfix]
  end

  def cached_collaborators
    return [] if @is_readonly
    Rails.cache.fetch(cache_key(:collaborators), expires_in: 20.minutes) do
      @github_api.collaborators(@board)
    end
  end

  def cached_labels
    return [] if @is_readonly
    Rails.cache.fetch(cache_key(:labels), expires_in: 20.minutes) do
      @github_api.labels(@board)
    end
  end
end
