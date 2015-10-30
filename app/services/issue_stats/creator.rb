module IssueStats
  class Creator
    pattr_initialize :user, :board_bag, :issue_info

    def call
      github_issue = user.github_api.create_issue(board_bag, issue_info)
      issue_stat = IssueStatService.create(board_bag, github_issue)

      IssueStats::Sorter.call(
        column_to: issue_stat.column,
        number: issue_stat.number,
        is_force_sort: true
      )
      Lifetimes::Starter.new(issue_stat, issue_stat.column).call
      board_bag.update_cache(github_issue)

      BoardIssue.new(github_issue, issue_stat)
    end
  end
end
