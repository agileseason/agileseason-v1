class GithubApi
  module Labels
    def sync_labels(board)
      repo_id = repo(board.github_id).id
      labels = client.labels(repo_id).map(&:name)
      missing_columns = board.columns.select { |column| column unless labels.include?(column.label_name) }
      missing_columns.each do |column|
        client.add_label(repo_id, column.label_name, column.color)
      end
    end
  end
end
