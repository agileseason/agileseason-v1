class RoadmapsController < ApplicationController
  before_action :fetch_board, only: [:show]

  helper_method :chart_issues, :chart_dates, :chart_issue_rows

  def show
  end

  private

  def chart_issues
    issues.to_json
  end

  def chart_dates
    [
      { from: 0, text: '06 Aug' },
      { from: 60, text: '07 Aug' }
    ].to_json
  end

  def chart_issue_rows
    issues.max { |e| e[:row] }[:row] + 1
  end

  def issues
    @issues ||=
      [
        { row: 0, from: 0, cycletime: 40, number: 84 },
        { row: 1, from: 0, cycletime: 140, number: 90 },
        { row: 0, from: 60, cycletime: 90, number: 75 }
      ]
  end
end
