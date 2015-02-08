class DurationService
  def initialize(board)
    @board = board
  end

  def fetch_group
    @board.issue_stats.closed.each_with_object({ 0 => 0 }) do |issue, hash|
      duration = issue.elapsed_days.to_i + 1
      count = hash[duration] || 0
      hash[duration] = count + 1
    end.sort
  end

  def average_forecast_elapsed_days
    @average_forecast_elapsed_days ||= begin
      if average_elapsed_days.present?
        (total_open_issues * average_elapsed_days).round(2)
      end
    end
  end

  def forecast_elapsed_days
    @forecast_elapsed_days ||= begin
      duration_groups = fetch_group
      if duration_groups.present?
        total_elapsed_days = duration_groups.sum { |pair| pair.first * pair.second }
        issues_count = duration_groups.sum(&:second)
        average_days = total_elapsed_days.to_f / issues_count
        (@board.issue_stats.open.count * average_days).round(0)
      end
    end
  end

  def average_elapsed_days
    @average_elapsed_days ||= begin
      if total_closed_issues > 0
        (@board.issue_stats.closed.map(&:elapsed_days).sum / total_closed_issues).round(2)
      end
    end
  end

  def total_open_issues
    @total_open_issues ||= @board.issue_stats.open.count
  end

  def total_closed_issues
    @total_closed_issues ||= @board.issue_stats.closed.count
  end
end
