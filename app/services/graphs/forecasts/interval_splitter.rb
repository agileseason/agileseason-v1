module Graphs
  module Forecasts
    class IntervalSplitter
      pattr_initialize :board

      def weeks
        (0..number_of_weeks).map do |index|
          from = (board.created_at + index.weeks).beginning_of_week
          to = (board.created_at + index.weeks).end_of_week
          (from..to)
        end
      end

      def months
      end

      private

      def number_of_weeks
        (Time.current - board.created_at).to_i / 1.week
      end
    end
  end
end
