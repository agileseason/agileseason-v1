class GithubApi
  module Issues
    def board_issues(board)
      board_labels = board.github_labels.each_with_object({}) { |label, hash| hash[label] = [] }
      client.issues(board.github_id).each do |issue|
        label = issue.labels.find { |e| board_labels.keys.include?(e.name) }
        board_labels[label.name] << issue if label
      end
      board_labels
    end

    def create_issue(board, issue)
      column = board.columns.first
      body = issue.body + TrackStats.track(column.id)
      client.create_issue(board.github_id, issue.title, body, labels: column.label_name)
    end

    def issue(board, number)
      client.issue(board.github_id, number)
    end

    def move_to(board, column, number)
      issue = client.issue(board.github_id, number)
      labels = issue.labels.map(&:name) - board.github_labels << column.label_name
      body = update_hidden_stats(issue.body, column)
      client.update_issue(board.github_id, number, issue.title, body, labels: labels)
    end

    private

    def update_hidden_stats(issue_body, column)
      data = TrackStats.extract(issue_body)
      hash = data[:hash]
      column_to_remove = column.board.columns.select { |c| c.order > column.order }.map(&:id)
      hash = TrackStats.remove_columns(hash, column_to_remove)
      data[:comment] + TrackStats.track(column.id, hash)
    end
  end
end
