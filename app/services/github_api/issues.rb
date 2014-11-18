class GithubApi
  module Issues
    def board_issues(board)
      labels = board.columns.map(&:label_name)
      issues = client.issues(board.github_id)
      board_labels = labels.inject({}) { |mem, e| mem[e] = []; mem }
      issues.each do |issue|
        label = issue.labels.find { |e| labels.include?(e.name) }
        board_labels[label.name] << issue if label
      end
      board_labels
    end

    def create_issue(board, issue)
      client.create_issue(board.github_id, issue.title, issue.body, { labels: board.columns.first.label_name })
    end
  end
end
