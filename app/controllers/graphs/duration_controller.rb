class Graphs::DurationController < ApplicationController
  before_action :fetch_board

  def index
    @chart_series_data = fetch_chart_duration_data
  end

  private

  def fetch_chart_duration_data
    @board.issue_stats.closed.each_with_object({}) do |issue, hash|
      duration = issue.elapsed_days.to_i + 1
      count = hash[duration] || 0
      hash[duration] = count + 1
    end.sort
  end
end
