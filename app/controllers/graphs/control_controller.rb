class Graphs::ControlController < ApplicationController
  include PreferenceHelper
  before_action :fetch_board
  helper_method :rolling_average_window

  def index
    @chart_series_data = {
      issues: builder.issues_series_data,
      average: builder.average_series_data,
      rolling_average: builder.rolling_average_series_data
    }
  end

  private

  def builder
    @builder ||= Graphs::ControlService.new(@board, rolling_average_window)
  end
end
