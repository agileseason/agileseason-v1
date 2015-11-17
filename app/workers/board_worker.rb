# TODO : Remove if unused until 01.08.2015
class BoardWorker
  include Sidekiq::Worker
  include GithubApiAccess
  sidekiq_options retry: 2
  sidekiq_options unique: :until_executing,
                  unique_args: -> (args) { [args.first] }

  def perform(board_id, encrypted_github_token)
    @board = Board.find(board_id)

    board_fetcher = BoardBagFetcher.new(github_api(encrypted_github_token), @board)
    board_fetcher.refresh_labels
    board_fetcher.refresh_collaborators
    board_fetcher.refresh_issues
  end
end
