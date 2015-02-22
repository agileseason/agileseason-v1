module Graphs
  class CumulativeBuilder
    def initialize(board)
      @board = board
    end

    def series
      fix_single_points(series_by_history)
    end

    private

    def fix_single_points(series)
      series.each do |column_id, series_data|
        data = series_data[:data]
        if data.size == 1
          # FIX : remove copy-paste from board_history.rb - line:16
          point0 = {
            column_id: data[0][:column_id],
            issues: 0,
            issues_cumulative: 0,
            # FIX : add to_js method for Time
            collected_on: (Time.at(data[0][:collected_on] / 1000) - 1.day).utc.to_i * 1000
          }
          data.insert(0, point0)
        end
      end
    end

    def series_by_history
      @board.board_histories.each_with_object(init_series) do |history, series|
        history.data.each do |column_data|
          point = column_data.merge(
              collected_on: history.collected_on.in_time_zone.to_js
          )
          series[column_data[:column_id]][:data] << point if series[column_data[:column_id]]
        end
      end
    end

    def init_series
      @board.columns.each_with_object({}) do |column, hash|
        hash[column.id] = { name: column.name, data: [] }
      end
    end
  end
end
