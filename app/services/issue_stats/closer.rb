module IssueStats
  class Closer
    include Service
    include Virtus.model
    include IdentityHelper

    attribute :user, User
    attribute :board_bag, BoardBag
    attribute :number, Integer

    def call
      issue = user.github_api.close(board_bag, number)
      board_bag.update_cache(issue)
      issue_stat.update!(closed_at: issue.closed_at)

      issue_stat
    end
  end
end
