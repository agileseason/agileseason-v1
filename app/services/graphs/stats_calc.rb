module Graphs
  class StatsCalc
    class << self
      def average_wip(issues_slice)
        return 0 if issues_slice.try(:blank?)
        elapsed_days = issues_slice.map(&:elapsed_days)
        elapsed_days.sum / elapsed_days.size
      end
    end
  end
end
