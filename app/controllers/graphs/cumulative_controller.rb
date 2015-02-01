class Graphs::CumulativeController < ApplicationController
  before_action :fetch_board

  def index
    @series = chart_series
  end

  private

  def chart_series
    @board.board_histories.each_with_object(init_series) do |history, series|
      history.data.each do |column_data|
        point = column_data.merge(
            collected_on: history.collected_on.in_time_zone.to_js
        )
        series[column_data[:column_id]][:data] << point
      end
    end
  end

  def init_series
    @board.columns.each_with_object({}) do |column, hash|
      hash[column.id] = { name: column.name, data: [] }
    end
  end
end
