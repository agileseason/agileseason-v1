module IssueStats
  class Finder
    pattr_initialize :user, :board_bag, :number

    def call
      IssueStatService.find(board_bag, number) ||
        IssueStatService.create!(board_bag, github_issue, user)
    end

    private

    def github_issue
      user.github_api.issue(board_bag, number)
    end
  end
end
