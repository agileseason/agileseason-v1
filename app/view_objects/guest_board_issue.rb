class GuestBoardIssue < BoardIssue
  rattr_initialize :user, :board, :issue, :issue_stat

  def comments
    return 0 if issue == GithubApiGuest::UNKNOWN_BOARD_ISSUE || issue_stat.nil?
    comments = Cached::Comments.call(user: user, board: issue_stat.board, number: issue_stat.number)
    comments.size
  end

  def due_date_at_to_js
    return unless issue_stat
    super
  end

  def ready?
    return unless issue_stat
    super
  end
end
