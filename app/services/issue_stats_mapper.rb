class IssueStatsMapper
  def initialize(board)
    @board = board
  end

  def [](issue)
    issue_stats_map[issue.number] || fix_missing(issue)
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

  def fix_missing(issue)
    issue_stats_map[issue.number] = IssueStatService.find_or_create_issue_stat(@board, issue) if actual?(issue)
  end

  def actual?(issue)
    issue.state == 'open' || (!first_import? && new?(issue))
  end

  def first_import?
    last_number == 0
  end

  def new?(issue)
    issue.number > last_number
  end

  # FIX : Remove duplicates with IssueStatsWroker.
  def last_number
    @last_number ||= @board.issue_stats.maximum(:number).to_i
  end
end
