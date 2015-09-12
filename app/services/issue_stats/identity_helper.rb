module IssueStats
  module IdentityHelper
    def issue_stat
      @issue_stat ||= IssueStats::Finder.new(user, board_bag, number).call
    end

    def github_issue
      @github_issue ||= user.github_api.issue(board_bag, number)
    end
  end
end
