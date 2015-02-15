class GithubApi
  module Labels
    def labels(board)
      client.labels(board.github_id).sort_by(&:name)
    end
  end
end
