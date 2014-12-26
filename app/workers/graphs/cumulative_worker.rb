class Graphs::CumulativeWorker < Graphs::BaseWorker
  def perform(board_id, github_token)
    board = Board.find(board_id)
    board_issues = GithubApi.new(github_token).board_issues(board)
    fill_missing_days(board.board_histories)
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
    find_board_history(board) || create_board_history(board)
  end

  def find_board_history(board)
    board.board_histories.where(collected_on: Date.today).first
  end

  def create_board_history(board)
    board.board_histories.create(collected_on: Date.today)
  end
end
