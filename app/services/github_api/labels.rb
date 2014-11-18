class GithubApi
  module Labels
    def sync_labels(board)
      labels = client.labels(board.github_id).map(&:name)
      missing_columns = board.columns.select { |column| column unless labels.include?(column.label_name) }
      missing_columns.each do |column|
        client.add_label(board.github_id, column.label_name, column.color)
      end
    end
  end
end
