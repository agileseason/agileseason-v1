module IssueStats
  class Mover
    pattr_initialize :user, :board_bag, :column_id, :number, :is_force

    def process
      assign if need_assignee?
      IssueStatService.move!(column, issue_stat, user, is_force)
    end

    # NOTE Public until end refactoring

    def column
      board.columns.find(column_id)
    end

    def issue_stat
      @issue_stat ||= IssueStatService.find(board, number) ||
        IssueStatService.create!(board, board_bag.github_api.issue(board, number), user)
    end

    private

    def board
      board_bag.board
    end

    def need_assignee?
      column.auto_assign? && board_bag.issue(number).assignee.nil?
    end

    def assign
      issue = board_bag.github_api.assign(board, number, user.github_username)
      board_bag.update_cache(issue)
    end
  end
end
