module IssueStats
  class Sorter
    include Service
    include Virtus.model
    include IdentityHelper

    attribute :column_to, Column
    attribute :number, Integer
    attribute :is_force_sort, Boolean

    def call
      return unless is_force_sort

      issues_ids = column_to.issues.unshift(number)
      column_to.update_sort_issues(issues_ids)
    end
  end
end
