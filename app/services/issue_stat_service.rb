class IssueStatService
  def self.create!(board, github_issue)
    board.issue_stats.create!(
      number: github_issue.number,
      created_at: github_issue.created_at,
      updated_at: github_issue.updated_at,
      closed_at: github_issue.closed_at,
      track_data: TrackStats.track_data(board.columns.first.id),
    )
  end

  def self.update!(issue_stat, github_issue)
    issue_stat.update(
      created_at: github_issue.created_at,
      updated_at: github_issue.updated_at,
      closed_at: github_issue.closed_at
    )
  end
end
