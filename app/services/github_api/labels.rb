class GithubApi
  module Labels
    def sync_labels(board)
      labels = labels_all(board).map(&:name)
      missing_columns = board.columns.reject { |column| labels.include?(column.label_name) }
      missing_columns.each do |column|
        client.add_label(board.github_id, column.label_name, column.color)
      end
    end

    def labels(board)
      columns_names = board.columns.map(&:label_name)
      labels_all(board).reject { |label| columns_names.include?(label.name) }
    end

    def labels_all(board)
      client.labels(board.github_id).sort_by(&:name)
    end
  end
end
