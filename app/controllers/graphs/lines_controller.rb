class Graphs::LinesController < ApplicationController
  before_action :fetch_board

  def index
    render text: "lines: #{@board.repo_histories.try(:last).try(:lines).to_i}"
  end
end
