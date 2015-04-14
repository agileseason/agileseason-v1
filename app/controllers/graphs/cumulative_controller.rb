class Graphs::CumulativeController < ApplicationController
  before_action :fetch_board

  def index
    @series = Graphs::CumulativeBuilder.new(@board, interval).series
  end

  private

  def interval
    params[:interval] && params[:interval] == 'month' ? :month : :all
  end
end
