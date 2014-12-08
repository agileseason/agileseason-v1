class GithubApi
  module Issues
    def board_issues(board)
      issues = client.issues(board.github_id)
      board_labels = board.github_labels.inject({}) { |mem, e| mem[e] = []; mem }
      issues.each do |issue|
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
      data = TrackStats.extract(issue.body)
      hash = data[:hash]
      column_to_remove = board.columns.select { |c| c.order > column.order }.map(&:id)
      hash = TrackStats.remove_columns(hash, column_to_remove)
      body = data[:comment] + TrackStats.track(column.id, hash)
      client.update_issue(board.github_id, number, issue.title, body, labels: labels)
    end
  end
end
