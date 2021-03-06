class BoardBag
  rattr_initialize :user, :board
  delegate :id, :github_id, :github_name, :github_full_name, :columns,
           :issue_stats, :to_param, :subscribed_at, :default_column, :public?,
           :user_id, to: :board

  # TODO Need more specs.
  def issue(number)
    issue = issues_hash[number]
    if readonly?
      issue ||= GithubApiGuest::UNKNOWN_BOARD_ISSUE
      GuestBoardIssue.new(user, @board, issue, issue_stat_mapper[issue])
    else
      issue ||= user.github_api.issue(board, number)
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
    @collaborators ||= Cached::Collaborators.
      call(user: user, board: @board).
      sort_by { |user| user.login.downcase }
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
    return github_repo.private if github_repo.present?
    board.private_repo?
  end

  def has_write_permission?
    return false if github_repo.nil?
    has_read_permission? && github_repo.permissions.push
  end

  def has_read_permission?
    github_repo.present? || !private_repo?
  end

  # TODO Remove duplication with Cached::Base#readonly?
  def readonly?
    user.guest? || !has_read_permission?
  end

  def subscribed?
    return true unless private_repo?

    subscribed_at.present? && subscribed_at >= Time.current
  end

  def direct_post
    @direct_post ||= S3Api.direct_post(user, @board)
  end

  def labels_to_json
    # TODO: Remove duplications with IssuePresenter
    labels.sort_by(&:name).map do |label|
      {
        id: label.name,
        name: label.name,
        color: "##{LabelPresenter.new(:label, label).font_color}",
        backgroundColor: "##{label.color}",
        checked: false
      }
    end.
      to_json
  end

private

  def issue_stat_mapper
    @issue_stat_mapper ||= IssueStatsMapper.new(self)
  end

  # FIX : Refactoring this method.
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
