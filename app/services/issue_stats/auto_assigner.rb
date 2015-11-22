module IssueStats
  class AutoAssigner
    include Service
    include Virtus.model
    include IdentityHelper

    attribute :user, User
    attribute :board_bag, BoardBag
    attribute :column, Column
    attribute :number, Integer

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
      issue
    end
  end
end
