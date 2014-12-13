class Graphs::CumulativeWorker
  include Sidekiq::Worker

  def perform(board_id, github_token)
    board = Board.find(board_id)
    board_history = fetch_board_history(board)
    github_api = GithubApi.new(github_token)
    board_issues = github_api.board_issues(board)
    board_history.update_data_issues(board_issues)
    board_history.save
  end

  private

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
