class Graphs::CumulativeController < ApplicationController
  before_action :fetch_board

  def index
    @series = Graphs::CumulativeBuilder.new(@board).series
  end
end
