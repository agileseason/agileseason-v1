class Graphs::CumulativeController < ApplicationController
  before_action :fetch_board

  def index
    @series = CumulativeBuilder.new(@board).series
  end
end
