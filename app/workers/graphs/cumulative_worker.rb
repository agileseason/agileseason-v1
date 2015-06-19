module Graphs
  class CumulativeWorker < BaseWorker
    def perform(board_id, encrypted_github_token)
      board = Board.find(board_id)
      fill_missing_days(board.board_histories)
      board_issues = github_api(encrypted_github_token).board_issues(board)
      save_current_history(board, board_issues)
    end

    private

    def save_current_history(board, board_issues)
      board_history = fetch_board_history(board)
      board_history.update_data_issues(board_issues)
      board_history.save
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
  end
end
