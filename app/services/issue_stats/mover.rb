module IssueStats
  class Mover
    pattr_initialize :user, :board_bag, :column, :number, :is_force

    def call
      IssueStatService.move!(column, issue_stat, user, is_force)
    end

    # NOTE Public until end refactoring

    def issue_stat
      @issue_stat ||= IssueStatService.find(board, number) ||
        IssueStatService.create!(board, user.github_api.issue(board, number), user)
    end

    private

    def board
      board_bag.board
    end
  end
end
