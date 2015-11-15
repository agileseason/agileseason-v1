class BoardBag
  rattr_initialize :user, :board
  delegate :github_id, :github_name, :github_full_name, :columns, :issue_stats,
           :to_param, :subscribed_at, :default_column, to: :board

  def issue(number)
    if user.guest?
      issue = issues_hash[number] || GithubApiGuest::UNKNOWN_BOARD_ISSUE
      GuestBoardIssue.new(issue, issue_stat_mapper[issue])
    else
      issue = issues_hash[number] || user.github_api.issue(board, number)
      BoardIssue.new(issue, issue_stat_mapper[issue])
    end
  end

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
    @issues_hash ||= Cached::Issues.call(user: user, board: @board)
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

  # TODO not update cache if data old or eq
  def update_cache(github_issue)
    issues_hash[github_issue.number] = github_issue
    Cached::UpdateIssues.call(board: @board, objects: issues_hash)
  end

  def collaborators
    return [] unless has_write_permission?
    @collaborators ||= Cached::Collaborators.call(user: user, board: @board)
  end

  def labels
    @labels ||= Cached::Labels.call(user: user, board: @board)
  end

  def build_issue_new
    Issue.new(labels: labels.map(&:name))
  end

  # FIX : Refactoring this method.
  def column_issues(column)
    if column.issues
      ordered_issues(column, column.issues) +
        ordered_issues(column, missing_issue_numbers(column))
    else
      if issues[column.id]
        issues[column.id].reject(&:archive?)
      else
        []
      end
    end
  end

  def private_repo?
    github_repo.present? && github_repo.private
  end

  def has_write_permission?
    has_read_permission? && github_repo.permissions.push
  end

  # TODO Return true if repository public!
  def has_read_permission?
    github_repo.present?
  end

  def subscribed?
    return true unless private_repo?

    subscribed_at.present? && subscribed_at >= Time.current
  end

  private

  def issue_stat_mapper
    @issue_stat_mapper ||= IssueStatsMapper.new(self)
  end

  def ordered_issues(column, issue_numbers)
    issue_numbers.map do |number|
      issues_by_columns[column.id].detect do |issue|
        number.to_i == issue.number && !issue.archive?
      end
    end.
      compact.
      uniq(&:number) # NOTE Need for remove magic duplication.
  end

  def missing_issue_numbers(column)
    issues_by_columns[column.id].map(&:number) - column.issues.map(&:to_i)
  end

  def github_repo
    @cached_repo ||= Boards::DetectRepo.call(user: user, board: board)
  end
end
