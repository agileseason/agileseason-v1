module Graphs
  class LinesWorker < BaseWorker
    def perform(board_id, github_token)
      board = Board.find(board_id)
      fill_missing_days(board.repo_histories)
      repo_lines = GithubApi.new(github_token).repo_lines(board)
      save_current_history(board, repo_lines) if repo_lines > 0
    end

    private

    def save_current_history(board, repo_lines)
      repo_history = fetch_repo_history(board)
      repo_history.lines = repo_lines
      repo_history.save
      repo_history
    end

    def fetch_repo_history(board)
      find_repo_history(board) || create_repo_history(board)
    end

    def find_repo_history(board)
      board.repo_histories.where(collected_on: Date.today).first
    end

    def create_repo_history(board)
      board.repo_histories.create(collected_on: Date.today)
    end
  end
end
