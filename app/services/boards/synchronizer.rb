module Boards
  class Synchronizer
    include Service
    include Virtus.model

    attribute :user, User
    attribute :board, Board

    def call
      archive_not_actual_issues
      move_archived_issues_to_last_column
    end

    private

    def issues
      @issues ||= user.github_api.issues(board)
    end

    def not_actual_issue_stats
      numbers_on_board = issues.map(&:number)
      board.issue_stats.visible.where.not(number: numbers_on_board)
    end

    def archive_not_actual_issues
      not_actual_issue_stats.each do |issue_stat|
        IssueStats::Archiver.call(
          user: user,
          board_bag: BoardBag.new(user, board),
          number: issue_stat.number
        )
      end
    end

    def move_archived_issues_to_last_column
      last_column = board.columns.last
      board.
        issue_stats.
        archived.
        where.not(column_id: last_column.id).
        update_all(column_id: last_column.id)
    end
  end
end
