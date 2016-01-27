module Graphs
  class ForecastsController < ApplicationController
    before_action :fetch_board

    def index
      @data = Graphs::Forecasts::Builder.new(
        @board.issue_stats,
        Graphs::Forecasts::IntervalSplitter.new(@board).weeks
      ).call
    end
  end
end
