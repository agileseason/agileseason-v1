class Graphs::LinesWorker
  include Sidekiq::Worker

  def perform(board_id, github_token)
    board = Board.find(board_id)
    github_api = GithubApi.new(github_token)
    repo_history = fetch_repo_history(board)
    repo_history.lines = github_api.repo_lines(board)
    repo_history.save
  end

  private

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
