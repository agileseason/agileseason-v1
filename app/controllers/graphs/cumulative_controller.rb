class Graphs::CumulativeController < ApplicationController
  before_action :fetch_board
  after_action :fetch_cumulative_graph

  def index
    @builder = Graphs::CumulativeBuilder.new(@board, interval)
  end

  private

  def interval
    params[:interval] && params[:interval] == 'month' ? :month : :all
  end

  def fetch_cumulative_graph
    return unless @board.board_histories.where(collected_on: Date.today).blank?
    Graphs::CumulativeWorker.perform_async(@board.id, encrypted_github_token)
  end
end
