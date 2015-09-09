module IssueStats
  class AutoAssigner
    pattr_initialize :user, :board_bag, :column, :number

    def call
      assign if need_assignee?
    end

    private

    def need_assignee?
      column.auto_assign? && current_assignee.nil?
    end

    def assign
      issue = user.github_api.assign(board_bag, number, user.github_username)
      board_bag.update_cache(issue)
    end

    def current_assignee
      user.github_api.issue(board_bag, number).assignee
    end
  end
end
