class GithubApiGuest
  REPOS = [].freeze
  UNKNOWN_BOARD_ISSUE = OpenStruct.new(
    number: 0,
    title: 'UNKNOWN',
    comments: 0,
    issue_stat: OpenStruct.new(
      column_id: 0,
    ),
  ).freeze

  def cached_repos
    REPOS
  end

  def issue(board, number)
    raise NoGuestDataError
  end
end
