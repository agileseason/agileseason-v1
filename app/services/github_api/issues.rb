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

    def issue(board, number)
      client.issue(board.github_id, number)
    end

    def move_to(board, column, number)
      issue = client.issue(board.github_id, number)
      /(.*)\n<!---\s@agileseason:(.*)\s-->(.*)/im =~ issue.body
      hash = eval($2)
# track all - set out_at
      hash[:track_stats][:columns].each do |key, value|
        value[:out_at] = Time.current.to_s
      end
# track current in
      hash[:track_stats][:columns][column.id] = { in_at: Time.current.to_s, out_at: nil }

      labels = issue.labels.map(&:name) - board.columns.map(&:label_name) << column.label_name
      body = "#{$1}#{hidden_content(hash)}#{$3}"
      client.update_issue(board.github_id, number, issue.title, body, { labels: labels })
    end

    private

    def hidden_track(column)
      hidden_content({
        track_stats: {
          columns: {
            column.id => {
              in_at: Time.current.to_s,
              out_at: nil
            }
          }
        }
      })
    end

    def hidden_content(hash)
      "\n<!---\n@agileseason:#{hash}\n-->"
    end
  end
end
