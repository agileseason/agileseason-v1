class IssueStatsMapper
  def initialize(board)
    @board = board
  end

  def [](issue)
    issue_stat = issue_stats_map[issue.number]
    unless issue_stat
      issue_stat = IssueStatService.find_or_create_issue_stat(@board, issue)
      issue_stats_map[issue.number] = issue_stat
    end
    issue_stat
  end

  private

  def issue_stats
    @issue_stats ||= board.issue_stats
  end

  def issue_stats_map
    @issue_stats_map ||= @board.issue_stats.each_with_object({}) do |issue_stat, hash|
      hash[issue_stat.number] = issue_stat
    end
  end
end
