class BoardBag
  pattr_initialize :github_api, :board
  delegate :github_id, :github_name, :github_full_name, :columns, :issue_stats,
           :to_param, :subscribed_at, to: :board

  # All issues
  def issues
    issues_hash.values
  end

  # Issues visible on board
  def board_issues
    @board_issues ||= issues.map do |issue|
      issue_stat = issue_stat_mapper[issue]
      BoardIssue.new(issue, issue_stat) if issue_stat
    end.compact
  end

  # All Issues in hash by number
  def issues_hash
    @issues_hash ||= cached(:issues_hash, 5.minutes) do
      github_api.issues(board).each_with_object({}) do |issue, hash|
        hash[issue.number] = issue
      end
    end
  end

  # Issues visible on board and groupped by columns
  def issues_by_columns
    @issues_by_columns ||= begin
      result_hash = board.columns.each_with_object({}) do |column, hash|
        hash[column.id] = []
      end

      board_issues.each_with_object(result_hash) do |board_issue, hash|
        hash[board_issue.column_id] << board_issue
      end
    end
  end

  def update_cache(issue)
    issues_hash[issue.number] = issue
    Rails.cache.write(
      cache_key(:issues_hash),
      issues_hash,
      expires_in: 5.minutes
    )
  end

  def collaborators
    @collaborators ||= cached(:collaborators, 20.minutes) do
      @github_api.collaborators(@board)
    end
  end

  def labels
    @labels ||= cached(:labels, 15.minutes) { @github_api.labels(@board) }
  end

  def build_issue_new
    Issue.new(labels: labels.map(&:name))
  end

  # FIX : Refactoring this method.
  def column_issues(column)
    if column.issues
      ordered_issues(column) + unordered_issues(column)
    else
      if issues[column.id]
        issues[column.id].reject(&:archive?)
      else
        []
      end
    end
  end

  def default_column
    columns.first
  end

  def private_repo?
    repo = @github_api.cached_repos.detect { |r| r.full_name == @board.github_full_name }
    repo.present? && repo.private
  end

  def subscribed?
    return true unless private_repo?

    subscribed_at.present? && subscribed_at >= Time.current
  end

  private

  def issue_stat_mapper
    @issue_stat_mapper ||= IssueStatsMapper.new(board)
  end

  def ordered_issues(column)
    column.issues.each_with_object([]) do |number, array|
      one_issue = issues_by_columns[column.id].detect do |issue|
        number.to_i == issue.number && !issue.archive?
      end
      array << one_issue if one_issue.present?
    end
  end

  def unordered_issues(column)
    issues_by_columns[column.id].select do |issue|
      !ordered_issues(column).include?(issue) && !issue.archive?
    end
  end

  def cache_key(posfix)
    if posfix == :issues_hash
      "board_bag_#{posfix}_#{board.id}_#{board.updated_at.to_i}"
    else
      "board_bag_#{posfix}_#{board.id}"
    end
  end

  def cached(posfix, expires_in, &block)
    if Rails.env.test?
      block.call
    else
      Rails.cache.fetch(cache_key(posfix), expires_in: expires_in) do
        block.call
      end
    end
  end
end
