module Graphs
  class CumulativeWorker < BaseWorker
    def perform(board_id, encrypted_github_token)
      board = Board.find(board_id)
      fill_missing_days(board.board_histories)

      board_bag = BoardBag.new(github_api(encrypted_github_token), board)
      save_current_history(
        board,
        board_bag.issues_by_columns
      )
    end

    private

    def save_current_history(board, issues_by_columns)
      board_history = fetch_board_history(board)
      board_history.update(data: fetch_data(board, issues_by_columns))
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

    def fetch_data(board, board_issues)
      issues_group = board_issues.each_with_object({}) do |pair, hash|
        column_id = pair[0]
        issues = pair[1]
        hash[column_id] = calc_issues(issues)
      end

      total_issues = total_issues_count(board, issues_group)
      data = {}
      data = board.columns.each_with_object([]) do |column, arr|
        count = issues_group[column.id] || 0
        arr << {
          column_id: column.id,
          issues: count,
          issues_cumulative: total_issues
        }
        total_issues -= count
      end
    end

    def calc_issues(issues)
      return 0 if issues.blank?
      issues.select { |issue| !issue.archive? }.size
    end

    def total_issues_count(board, issues_group)
      board_total = issues_group.sum { |e| e[1] }
      board.issue_stats.archived.count + board_total
    end
  end
end
