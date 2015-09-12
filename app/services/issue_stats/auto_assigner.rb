module IssueStats
  class AutoAssigner
    include IdentityHelper

    pattr_initialize :user, :board_bag, :column, :number

    def call
      assign if need_assignee?
    end

    private

    def need_assignee?
      column.auto_assign? && github_issue.assignee.nil?
    end

    def assign
      issue = user.github_api.assign(board_bag, number, user.github_username)
      board_bag.update_cache(issue)
    end
  end
end
