class GithubApi
  module Stats
    def repo_lines(board)
      stats = client.code_frequency_stats(board.github_id)
      if stats.blank?
        0
      else
        stats.map { |e| e[1] + e[2] }.sum
      end
    end
  end
end
