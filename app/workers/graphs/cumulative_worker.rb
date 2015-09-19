module Graphs
  class CumulativeWorker < BaseWorker
    def perform(board_id, encrypted_github_token)
      board = Board.find(board_id)
      fill_missing_days(board.board_histories)

      user = board.user
      user.github_api = github_api(encrypted_github_token)
      Boards::Synchronizer.call(user: user, board: board)

      save_current_history(board)
    end

    private

    def save_current_history(board)
      board_history = fetch_board_history(board)
      board_history.update(data: fetch_data(board))
      board_history
    end

    def fetch_board_history(board)
      find_board_history(board) || build_board_history(board)
    end

    def find_board_history(board)
      board.board_histories.where(collected_on: Date.today).first
    end

    def build_board_history(board)
      board.board_histories.build(collected_on: Date.today)
    end

    # TODO Extract service
    def fetch_data(board)
      total_issues = board.issue_stats.count
      board.columns.each_with_object([]) do |column, arr|
        count = issues_count(board, column)
        arr << {
          column_id: column.id,
          issues: count,
          issues_cumulative: total_issues
        }
        total_issues -= count
      end
    end

    def issues_count(board, column)
      group = issues_group(board).detect { |g| g.column_id == column.id }
      return 0 if group.nil?
      group.issues
    end

    def issues_group(board)
      @issues_group ||= board.
        issue_stats.
        select('column_id, count(*) as issues').
        group(:column_id)
    end
  end
end
