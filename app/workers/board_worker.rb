class BoardWorker
  include Sidekiq::Worker
  include GithubApiAccess
  sidekiq_options Sidekiq::UNIQUE_OPTIONS
  sidekiq_options retry: 2

  def perform(board_id, encrypted_github_token)
    @board = Board.find(board_id)

    board_fetcher = BoardBagFetcher.new(github_api(encrypted_github_token), @board)
    board_fetcher.refresh_labels
    board_fetcher.refresh_collaborators
    board_fetcher.refresh_issues
  end
end
