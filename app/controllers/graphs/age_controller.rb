class Graphs::AgeController < ApplicationController
  before_action :fetch_board

  def index
    @data = Graphs::AgeBuilder.new(@board_bag).chart_data
  end
end
