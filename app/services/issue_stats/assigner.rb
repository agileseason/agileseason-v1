module IssueStats
  class Assigner
    include IdentityHelper
    include Service
    include Virtus.model

    attribute :user, User
    attribute :board_bag, BoardBag
    attribute :number, Integer
    attribute :login, String

    def call
      github_issue = user.github_api.assign(board_bag, number, login)
      board_bag.update_cache(github_issue)
      BoardIssue.new(github_issue, issue_stat)
    end
  end
end
