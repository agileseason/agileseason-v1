class GithubApi
  module Issues
    def board_issues(board)
      board_labels = board.github_labels.each_with_object({}) { |label, hash| hash[label] = [] }
      all_issues(board).each do |issue|
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

    def close(board, number)
      client.close_issue(board.github_id, number)
    end

    def assign_yourself(board, number, github_username)
      # FIX : Get issue - don't work override, error: Wrong number of arguments. Expected 4 to 5, got 3.
      issue = client.issue(board.github_id, number)
      # FIX : Don't work - client.update_issue(board.github_id, number, assignee: github_username)
      client.update_issue(board.github_id, number, issue.title, issue.body, assignee: github_username)
    end

    private

    def update_hidden_stats(issue_body, column)
      data = TrackStats.extract(issue_body)
      hash = data[:hash]
      column_to_remove = column.board.columns.select { |c| c.order > column.order }.map(&:id)
      hash = TrackStats.remove_columns(hash, column_to_remove)
      data[:comment].to_s + TrackStats.track(column.id, hash)
    end

    def all_issues(board)
      open_issues(board) + closed_issues(board)
    end

    def open_issues(board)
      client.issues(board.github_id)
    end

    def closed_issues(board)
      client.issues(board.github_id, state: :closed)
    end
  end
end
