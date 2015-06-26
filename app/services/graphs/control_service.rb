module Graphs
  class ControlService
    def initialize(board, issue_link_getter = -> (number) {})
      @board = board
      @issue_link_getter = issue_link_getter
    end

    def issues_series_data
      issues.map do |issue|
        {
          x: issue.closed_at.to_js,
          y: issue.elapsed_days,
          number: issue.number,
          url: @issue_link_getter.call(issue.number)
        }
      end
    end

    def average_series_data
      return [] if issues.blank?
      average_level = StatsCalc.average_wip(issues)
      [issues.first, issues.last].uniq.compact.map do |issue|
        { x: issue.closed_at.to_js, y: average_level }
      end
    end

    def rolling_average_series_data
      return [] if issues.blank?
      rolling_average = issues.each_slice(rolling_window).map do |slice_issues|
        rolling_average_level = StatsCalc.average_wip(slice_issues)
        issue = slice_issues.last
        rolling_point(issue, rolling_average_level)
      end

      if rolling_average.first[:x] >= issues.first.closed_at.to_js
        rolling_average.insert(0, rolling_point(issues.first, 0))
      end

      rolling_average
    end

    private

    def rolling_point(issue, value)
      { x: issue.closed_at.to_js, y: value, window: rolling_window }
    end

    def rolling_window
      @rolling_window ||= @board.kanban_settings.rolling_average_window
    end

    def issues
      @issues ||= @board.issue_stats.closed.order(:closed_at)
    end
  end
end
