module Graphs
  class ForecastController < ApplicationController
    before_action :fetch_board

    def index
      @builder = Graphs::ForecastBuilder.new(@board)
    end
  end
end
