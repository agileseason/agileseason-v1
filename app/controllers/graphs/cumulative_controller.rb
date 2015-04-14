class Graphs::CumulativeController < ApplicationController
  before_action :fetch_board

  def index
    @builder = Graphs::CumulativeBuilder.new(@board, interval)
  end

  private

  def interval
    params[:interval] && params[:interval] == 'month' ? :month : :all
  end
end
