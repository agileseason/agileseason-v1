class Graphs::LinesController < ApplicationController
  before_action :fetch_board

  def index
    @lines = @board.repo_histories.map(&:lines)
  end
end
