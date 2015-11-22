module Graphs
  class FrequencyController < ApplicationController
    before_action :fetch_board

    helper_method :stat_to_html

    def index
      @frequency_all = FrequencyService.new(@board, @board.created_at)
      @frequency_month = FrequencyService.new(@board, [1.month.ago, @board.created_at].max)
    end

    private

    def stat_to_html(value)
      value.nil? ? '-' : value.round(2)
    end
  end
end
