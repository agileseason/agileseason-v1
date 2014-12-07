class GithubApi
  module Stats
    def repo_lines(board)
      stats = client.code_frequency_stats(board.github_id)
      unless stats.blank?
        stats.map{ |e| e[1] + e[2]}.sum
      else
        0
      end
    end
  end
end

