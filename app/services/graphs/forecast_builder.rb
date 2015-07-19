module Graphs
  class ForecastBuilder
    pattr_initialize :board

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
        issues_count = column.issue_stats.open.count
        data = {
          issues: issues_count,
          y: forecast_days(issues_count)
        }
        array << data
      end
      build_tooltip(series)
      series
    end

    private

    def build_tooltip(series)
      total_y = 0

      series.reverse.each_with_index do |hash, index|
        y = hash[:y]
        finish_date = Time.current + y.days
        hash[:tooltip] =
          "Open Issues: <b>#{hash[:issues]}</b>" +
          "<br/>Forecast by monthly throughput: <b>#{y}</b>d"

        total_y += y
        if index > 0
          previous_delay = total_y.round(2)
          finish_date += previous_delay.days
          hash[:tooltip] += "<br/>With previous delay: <b>#{previous_delay}</b>d"
        end

        hash[:tooltip] += "<br/>Finish Date: <b>#{finish_date.strftime('%Y-%m-%d')}</b>"
      end
    end

    def issues_per_day
      @issues_per_day ||= FrequencyService.new(board, 1.month.ago).throughput
    end

    def forecast_days(issues_count)
      return issues_count if issues_per_day.nil? || issues_per_day.zero?
      (issues_count / issues_per_day).round(2)
    end
  end
end
