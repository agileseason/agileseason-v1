class GithubApi
  module Issues
    def board_issues(board)
      board_hash = board.github_labels.each_with_object({}) { |label, hash| hash[label] = [] }
      all_issues(board).each do |issue|
        label_name = find_label_name(board, issue)
        board_hash[label_name] << issue if label_name
      end
      board_hash
    end

    def create_issue(board, issue)
      column = board.columns.first
      body = issue.body + TrackStats.track([column.id])
      labels = issue.labels.reject(&:blank?) << column.label_name
      client.create_issue(board.github_id, issue.title, body, labels: labels)
    end

    def issue(board, number)
      client.issue(board.github_id, number)
    end

    # FIX : To many args.
    def move_to(board, column, number, issue = client.issue(board.github_id, number))
      body = update_hidden_stats(issue.body, column)
      client.update_issue(
        board.github_id,
        number,
        issue.title,
        body,
        labels: fetch_labels(issue, column)
      )
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

    def find_label_name(board, issue)
      column_names = board.github_labels
      label = issue.labels.find { |e| column_names.include?(e.name) }
      if label
        label.name
      elsif issue.state == 'open'
        column = board.columns.first
        move_to(board, column, issue.number, issue)
        column.label_name
      end
    end

    def fetch_labels(issue, column)
      (issue.labels.map(&:name) - column.board.github_labels) << column.label_name
    end

    def update_hidden_stats(issue_body, column)
      data = TrackStats.extract(issue_body)
      hash = data[:hash]
      hash = TrackStats.remove_columns(hash, column.next_columns.map(&:id))
      tracked_ids = column.prev_columns.map(&:id) << column.id
      data[:comment].to_s + TrackStats.track(tracked_ids, hash)
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
