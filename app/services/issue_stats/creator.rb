module IssueStats
  class Creator
    pattr_initialize :user, :board_bag, :issue_info

    def call
      github_issue = user.github_api.create_issue(board_bag, issue_info)
      issue_stat = IssueStatService.create(board_bag, github_issue)

      IssueStats::Sorter.new(issue_stat.column, issue_stat.number, true).call
      Lifetimes::Starter.new(issue_stat, issue_stat.column).call
      board_bag.update_cache(github_issue)

      BoardIssue.new(github_issue, issue_stat)
    end
  end
end
