module IssueStats
  class Sorter
    pattr_initialize :column_to, :number, :is_force_sort

    def call
      return unless is_force_sort

      issues_ids = column_to.issues.unshift(number)
      column_to.update_sort_issues(issues_ids)
    end
  end
end
