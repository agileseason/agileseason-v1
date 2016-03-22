module Graphs
  class FrequencyController < ApplicationController
    before_action :fetch_board

    helper_method :stat_to_html

    def index
      @frequency = FrequencyService.new(@board, from_at)
    end

    private

    def from_at
      return [1.month.ago, @board.created_at].max unless params[:from]
      Time.parse(params[:from])
    end

    def stat_to_html(value)
      value.nil? ? '-' : value.round(2)
    end
  end
end
