class GuestBoardIssue < BoardIssue
  attr_initialize :issue, :issue_stat

  def comments
    0
  end

  def column_id
    0
  end

  def due_date_at
    nil
  end
end
