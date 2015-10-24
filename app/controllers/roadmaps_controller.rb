class RoadmapsController < ApplicationController
  before_action :fetch_board, only: [:show]

  helper_method :chart_issues, :chart_dates, :chart_now

  def show
  end

  private

  def chart_issues
    roadmap.issues.to_json
  end

  def chart_dates
    roadmap.dates.to_json
  end

  def chart_now
    roadmap.current_date.to_json
  end

  private

  def roadmap
    @roadmap ||= Roadmap.call(board_bag: @board_bag)
  end
end
