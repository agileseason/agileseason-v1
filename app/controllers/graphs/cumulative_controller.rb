class Graphs::CumulativeController < ApplicationController
  before_action :fetch_board

  def index
    @data = @board.board_histories.map(&:data)
  end
end
