class Graphs::CumulativeController < ApplicationController
  before_action :fetch_board

  helper_method :point_start, :chart_categories

  def index
    @series = @board.board_histories.each_with_object(init_series) do |history, series|
      history.data.each do |column_data|
        series[column_data[:column_id]][:data] << column_data[:issues_cumulative]
      end
    end
  end

  # FIX : Remove if unnecessary.
  def point_start
    @board.board_histories.first.try(:collected_on) || Date.today
  end

  def chart_categories
    @board.board_histories.map(&:collected_on).map(&:strftime)
  end

  private

  def init_series
    @board.columns.each_with_object({}) do |column, hash|
      hash[column.id] = { name: column.name, data: [] }
    end
  end
end
