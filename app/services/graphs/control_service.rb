module Graphs
  class ControlService
    def initialize(board)
      @board = board
    end

    def issues_series_data
      issues.map do |issue|
        { x: issue.closed_at.to_js, y: issue.elapsed_days, number: issue.number }
      end
    end

    def average_series_data
      return [] if issues.blank?
      elapsed_days = issues.map(&:elapsed_days)
      average_level = elapsed_days.sum / elapsed_days.size
      [issues.first, issues.last].uniq.compact.map do |issue|
        { x: issue.closed_at.to_js, y: average_level }
      end
    end

    private

    def issues
      @issues ||= @board.issue_stats.closed.order(:closed_at)
    end
  end
end
