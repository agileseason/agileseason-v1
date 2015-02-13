class GithubApi
  module Labels
    def labels(board)
      columns_names = board.columns.map(&:label_name)
      labels_all(board).reject { |label| columns_names.include?(label.name) }
    end

    def labels_all(board)
      client.labels(board.github_id).sort_by(&:name)
    end
  end
end
