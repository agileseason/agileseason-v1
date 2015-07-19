module Graphs
  class FrequencyController < ApplicationController
    before_action :fetch_board

    def index
      @frequency = ::FrequencyService.new(@board)
      @chart_series_all = @frequency.chart_series.sort
      @chart_series_month = @frequency.chart_series(1.month.ago).sort
    end
  end
end
