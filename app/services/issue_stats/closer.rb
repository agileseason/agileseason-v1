module IssueStats
  class Closer
    include IdentityHelper

    pattr_initialize :user, :board_bag, :number

    def call
      github_issue = user.github_api.close(board_bag, number)
      board_bag.update_cache(github_issue)
      issue_stat.update(closed_at: github_issue.closed_at)

      issue_stat
    end
  end
end
