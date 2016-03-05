module Graphs
  class AgeBuilder
    DEFAULT_STEP_DAYS_BASE = 14

    def initialize(board_bag, step_days_base = DEFAULT_STEP_DAYS_BASE)
      @board_bag = board_bag
      @step_days_base = step_days_base
    end

    def chart_data
      index = 0
      issues.map do |issue|
        {
          index: index += 1,
          number: issue.number,
          days: days_from(issue.created_at),
          age: age_group(issue.created_at),
          issue: IssuePresenter.new(:issue, issue).to_hash(@board_bag)
        }
      end
    end

    def issues
      @board_bag.board_issues.
        select(&:open?).
        sort_by(&:created_at)
    end

    def days_from(created_at)
      ((Time.current - created_at) / 1.day).round
    end

    def age_group(created_at)
      days = days_from(created_at)
      return :n0 if days <= @step_days_base
      return :n1 if days <= @step_days_base * 2
      return :n2 if days <= @step_days_base * 4
      return :n4 if days <= @step_days_base * 8
      :n8
    end
  end
end
