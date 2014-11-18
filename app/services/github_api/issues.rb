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
      column = board.columns.first
      full_body = issue.body + hidden_track(column)
      client.create_issue(board.github_id, issue.title, full_body, { labels: column.label_name })
    end

    private

    def hidden_track(column)
      hidden_content({
        track_stats: {
          column_id: column.id,
          in_at: Time.current.to_s,
          out_at: nil,
        }
      })
    end

    def hidden_content(hash)
      "\n<!---\n@agileseason:#{hash}\n-->"
    end
  end
end
