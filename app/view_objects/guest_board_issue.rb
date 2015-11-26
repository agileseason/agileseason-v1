class GuestBoardIssue < BoardIssue
  rattr_initialize :user, :issue, :issue_stat

  def comments
    return 0 if issue == GithubApiGuest::UNKNOWN_BOARD_ISSUE || issue_stat.nil?
    comments = Cached::Comments.call(user: user, board: issue_stat.board, number: issue_stat.number)
    comments.size
  end

  def column_id
    0
  end

  def due_date_at
    nil
  end
end
