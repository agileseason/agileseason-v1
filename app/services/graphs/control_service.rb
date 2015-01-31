module Graphs
  class ControlService
    def initialize(board)
      @board = board
    end

    def issues_series_data
      issues.map do |issue|
        {
          x: issue.closed_at.to_js,
          y: issue.elapsed_days,
          number: issue.number
        }
      end
    end

    def average_series_data
      return [] if issues.blank?
      average_level = average_level(issues)
      [issues.first, issues.last].uniq.compact.map do |issue|
        { x: issue.closed_at.to_js, y: average_level }
      end
    end

    def rolling_average_series_data
      return [] if issues.blank?
      rolling_window = @board.kanban_settings.rolling_average_window
      issues.each_slice(rolling_window).to_a.map do |slice_issues|
        rolling_average_level = average_level(slice_issues)
        issue = slice_issues.last
        { x: issue.closed_at.to_js, y: rolling_average_level, window: rolling_window }
      end
    end

    private

    def issues
      @issues ||= @board.issue_stats.closed.order(:closed_at)
    end

    def average_level(issues)
      elapsed_days = issues.map(&:elapsed_days)
      elapsed_days.sum / elapsed_days.size
    end
  end
end
