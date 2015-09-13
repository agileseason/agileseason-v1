module IssueStats
  class Reopener
    include IdentityHelper

    pattr_initialize :user, :board_bag, :number

    def call
      github_issue = user.github_api.reopen(board_bag, number)
      board_bag.update_cache(github_issue)
      issue_stat.update(closed_at: nil)

      issue_stat
    end
  end
end
