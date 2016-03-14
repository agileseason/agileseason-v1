module Graphs
  #class FrequencyBuilder
    #EMPTY = [0].freeze

    #pattr_initialize :issues

    #def chart_data
      #return EMPTY if issues.blank?
    #end
  #end

  class FrequencyService
    pattr_initialize :board, :from_at

    def issues
      @issues ||= board.
        issue_stats.
        closed.
        where('closed_at >= ?', from_at).
        to_a
    end

    def chart_data
      return zero_point if issues.blank?

      normolized = (1..max_cycle_time).each_with_object(zero_point) do |day, hash|
        hash[day] = 0
      end

      issues.each do |issue|
        duration = issue.elapsed_days.ceil
        normolized[duration] += 1
      end

      normolized
    end

    def avg_cycle_time
      return if issues.blank?

      (issues.sum(&:elapsed_days) / issues.count).round(2)
    end

    def avg_cycle_time_percentile(persentile)
      return if issues.blank?

      bound = percentile_elapsed_days_bound(persentile, issues.map(&:elapsed_days))
      percentile_issues = issues.select { |issue| issue.elapsed_days <= bound }
      (percentile_issues.sum(&:elapsed_days) / percentile_issues.count).round(2)
    end

    def throughput
      return if issues.blank?

      passed_days = (Time.current - from_at) / 86400
      issues.count / passed_days
    end

    private

    def percentile_elapsed_days_bound(percentile, elapsed_days)
      min, max = elapsed_days.minmax
      (max - min) * percentile + min
    end

    def zero_point
      { 0 => 0 }
    end

    def max_cycle_time
      issues.map(&:elapsed_days).max.ceil
    end
  end
end
