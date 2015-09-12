module IssueStats
  class Assigner
    include IdentityHelper

    pattr_initialize :user, :board_bag, :number, :login

    def call
      github_issue = user.github_api.assign(board_bag, number, login)
      board_bag.update_cache(github_issue)
      BoardIssue.new(github_issue, issue_stat)
    end
  end
end
