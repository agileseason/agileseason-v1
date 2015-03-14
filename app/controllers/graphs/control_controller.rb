class Graphs::ControlController < ApplicationController
  before_action :fetch_board

  def index
    @chart_series_data = chart_series_data
  end

  private

  def chart_series_data
    control_service = Graphs::ControlService.new(@board, board_url(@board))
    {
      issues: control_service.issues_series_data,
      average: control_service.average_series_data,
      rolling_average: control_service.rolling_average_series_data
    }
  end
end
