class CheckboxSynchronizer
  include Sidekiq::Worker
  include GithubApiAccess
  sidekiq_options retry: 1


  def perform(board_id, number, encrypted_github_token)
    board = Board.find(board_id)
    issue_stat = IssueStatService.find(board, number)
    return if issue_stat.nil?

    github_api = github_api(encrypted_github_token)
    comments = github_api.issue_comments(board, number)

    IssueStats::SyncChecklist.call(
      issue_stat: issue_stat,
      comments: comments
    )
  end
end
