class DurationService
  def initialize(board)
    @board = board
  end

  def fetch_group
    @board.issue_stats.closed.each_with_object({}) do |issue, hash|
      duration = issue.elapsed_days.to_i + 1
      count = hash[duration] || 0
      hash[duration] = count + 1
    end.sort
  end

  def forecast
    duration_groups = fetch_group
    if duration_groups.present?
      total_elapsed_days = duration_groups.sum { |pair| pair.first * pair.second }
      issues_count = duration_groups.sum(&:second)
      average_days = total_elapsed_days.to_f / issues_count
      (@board.issue_stats.open.count * average_days).round(0)
    end
  end
end
