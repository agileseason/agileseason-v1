class Graphs::LinesController < ApplicationController
  before_action :fetch_board
  helper_method :point_start

  def index
    @lines = @board.repo_histories.map(&:lines)
  end

  def point_start
    history_date = @board.repo_histories.try(:first).try(:collected_on) || Date.today
    Time.utc(history_date.year, history_date.month, history_date.day).to_i * 1000
  end
end
