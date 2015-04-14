module Graphs
  class ForecastBuilder
    def initialize(board)
      @board = board
    end

    def categories
      @board.columns.map(&:name)
    end

    def series_prev
      series = series_forecast.last(@board.columns.count - 1) << { issues: 0, y: 0 }
      total_wip = 0
      series.reverse_each do |hash|
        hash[:y] += total_wip
        total_wip = hash[:y]
      end
      series
    end

    def series_forecast
      series = @board.columns.each_with_object([]) do |column, array|
        issues = column.issue_stats.open.count
        forecast_day = (issues * forecast_wip).round(2)
        data = {
          issues: issues,
          y: forecast_day
        }
        array << data
      end
      build_tooltip(series)
      series
    end

    private

    def build_tooltip(series)
      total_y = 0
      index = 0
      series.reverse_each do |hash|
        issues = hash[:issues]
        y = hash[:y]
        total_y += y
        hash[:tooltip] = "Open Issues: <b>#{issues}</b><br/>By Average: <b>#{y}</b>d"
        hash[:tooltip] += "<br/>With previous delay: <b>#{total_y.round(2)}</b>d" unless index == 0
        index += 1
      end
    end

    def average_wip
      @average_wip ||= StatsCalc.average_wip(@board.issue_stats.closed)
    end

    def forecast_wip
      @forecast_wip ||= average_wip > 0 ? average_wip : 1
    end
  end
end
