module Graphs
  module Forecasts
    class Builder
      pattr_initialize :issues, :intervals

      def call
        result.each do |item|
          issues.each do |issue|
            if issue.created_at <= item.interval.last
              item.open += 1
            end

            if issue.closed_at && issue.closed_at <= item.interval.last
              item.closed += 1
            end
          end
        end
      end

      private

      def result
        @result ||= intervals.map do |interval|
          OpenStruct.new(
            interval: interval,
            open: 0,
            closed: 0
          )
        end
      end
    end
  end
end
