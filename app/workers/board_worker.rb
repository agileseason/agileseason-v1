class BoardWorker
  include Sidekiq::Worker
  sidekiq_options Sidekiq::UNIQUE_OPTIONS
  sidekiq_options retry: 2

  def perform(board_id, github_token)
    @board = Board.find(board_id)
    @github_api = GithubApi.new(github_token)

    board_fetcher = BoardBagFetcher.new(@github_api, @board)
    board_fetcher.refresh_labels
    board_fetcher.refresh_collaborators
    board_fetcher.refresh_issues
  end
end
