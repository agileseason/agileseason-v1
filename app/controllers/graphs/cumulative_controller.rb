class Graphs::CumulativeController < ApplicationController
  before_action :fetch_board

  def index
    @series = chart_series
    @categories = chart_categories
  end

  private

  def init_series
    @board.columns.each_with_object({}) do |column, hash|
      hash[column.id] = { name: column.name, data: [] }
    end
  end

  def chart_categories
    @board.board_histories.map(&:collected_on).map(&:strftime)
  end

  def chart_series
    @board.board_histories.each_with_object(init_series) do |history, series|
      history.data.each do |column_data|
        series[column_data[:column_id]][:data] << column_data
      end
    end
  end
end
