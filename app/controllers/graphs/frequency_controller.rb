module Graphs
  class FrequencyController < ApplicationController
    before_action :fetch_board

    def index
      @frequency = ::FrequencyService.new(@board)
      @chart_series = @frequency.chart_series
    end
  end
end
