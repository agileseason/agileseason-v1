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
      full_body = issue.body + TrackStats.track(column.id)
      client.create_issue(board.github_id, issue.title, full_body, { labels: column.label_name })
    end

    def issue(board, number)
      client.issue(board.github_id, number)
    end

    def move_to(board, column, number)
      issue = client.issue(board.github_id, number)
      /(.*)\n<!---\s@agileseason:(.*)\s-->(.*)/im =~ issue.body
      hash = eval($2)
      labels = issue.labels.map(&:name) - board.github_labels << column.label_name
      body = "#{$1}#{TrackStats.track(column.id, hash)}#{$3}"
      client.update_issue(board.github_id, number, issue.title, body, { labels: labels })
    end
  end
end
