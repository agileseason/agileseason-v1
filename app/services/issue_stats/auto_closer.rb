module IssueStats
  class AutoCloser
    include Service
    include Virtus.model
    include IdentityHelper

    attribute :user, User
    attribute :board_bag, BoardBag
    attribute :column, Column
    attribute :number, Integer

    def call
      if need_close?
        IssueStats::Closer.call(user: user, board_bag: board_bag, number: number)
      end
    end

    private

    def need_close?
      column.auto_close? && github_issue.state == 'open'
    end
  end
end
