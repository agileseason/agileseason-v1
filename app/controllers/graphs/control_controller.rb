class Graphs::ControlController < ApplicationController
  before_action :fetch_board

  def index
    @chart_series_data = fetch_issues_data
  end

  private

  def fetch_issues_data
    @board.issue_stats.closed.map do |issue|
      { x: issue.closed_at.to_js, y: issue.elapsed_days, number: issue.number }
    end
  end
end
