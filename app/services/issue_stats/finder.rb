module IssueStats
  class Finder
    include IdentityHelper

    pattr_initialize :user, :board_bag, :number

    def call
      IssueStatService.find(board_bag, number) ||
        IssueStatService.create(board_bag, github_issue)
    end
  end
end
