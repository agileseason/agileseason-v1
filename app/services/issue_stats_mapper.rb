class IssueStatsMapper
  pattr_initialize :board_bag

  def [](issue)
    issue_stats_map[issue.number] || fix_missing(issue)
  end

  private

  def issue_stats
    @issue_stats ||= board_bag.issue_stats
  end

  def issue_stats_map
    @issue_stats_map ||= board_bag.issue_stats.each_with_object({}) do |issue_stat, hash|
      hash[issue_stat.number] = issue_stat
    end
  end

  def fix_missing(issue)
    return unless actual?(issue)
    issue_stats_map[issue.number] = IssueStatService.create(board_bag, issue)
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
    @last_number ||= board_bag.issue_stats.maximum(:number).to_i
  end
end
