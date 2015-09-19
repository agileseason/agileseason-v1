module Graphs
  class CfdSnapshot
    include Service
    include Virtus.model

    attribute :board, Board

    def call
      total_issues = board.issue_stats.count
      board.columns.each_with_object([]) do |column, arr|
        count = issues_count(column)
        arr << {
          column_id: column.id,
          issues: count,
          issues_cumulative: total_issues
        }
        total_issues -= count
      end
    end

    private

    def issues_count(column)
      group = issues_group.detect { |g| g.column_id == column.id }
      return 0 if group.nil?
      group.issues
    end

    def issues_group
      @issues_group ||= board.
        issue_stats.
        select('column_id, count(*) as issues').
        group(:column_id)
    end
  end
end
