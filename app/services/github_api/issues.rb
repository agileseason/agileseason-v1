class GithubApi
  module Issues
    def issues(board)
      (open_issues(board) + closed_issues(board))
        .select { |issue| !issue.pull_request }
        .sort { |a, b| b.updated_at <=> a.updated_at }
    end

    def old_board_issues(board)
      board_hash = board.github_labels.each_with_object({}) { |label, hash| hash[label] = [] }
      issues(board).each do |issue|
        label_name = find_label_name(board, issue)
        board_hash[label_name] << issue if label_name
      end
      board_hash
    end

    def board_issues(board)
      result_hash = board.columns.each_with_object({}) { |column, hash| hash[column.id] = [] }
      mapper = IssueStatsMapper.new(board)
      issues(board).each_with_object(result_hash) do |issue, hash|
        issue_stat = mapper[issue]
        hash[issue_stat.column.id] << BoardIssue.new(issue, issue_stat)
      end
    end

    def create_issue(board, issue)
      github_issue = client.create_issue(board.github_id, issue.title, issue.body, labels: issue.labels)
      IssueStatService.create!(board, github_issue)
      github_issue
    end

    def issue(board, number)
      client.issue(board.github_id, number)
    end

    # FIX : To many args.
    def move_to(board, column, number, issue = client.issue(board.github_id, number))
      issue_stat = IssueStatService.move!(board, column, issue)
      # FIX : Add activities if column really changed.
      # FIX : Save info about previous column after #126
      Activities::ColumnChangedActivity.create_for(issue_stat, nil, column, @user)
      client.update_issue(
        board.github_id,
        number,
        issue.title,
        issue.body,
        labels: issue.labels
      )
    end

    def close(board, number)
      client.close_issue(board.github_id, number)
      IssueStatService.close!(board, client.issue(board.github_id, number))
    end

    def archive(board, number)
      issue = client.issue(board.github_id, number)
      return if issue.state == 'open'
      issue_stat = IssueStatService.archive!(board, issue)
      Activities::ArchiveActivity.create_for(issue_stat, @user)
      issue_stat
    end

    def assign_yourself(board, number, github_username)
      # FIX : Get issue - don't work override, error: Wrong number of arguments. Expected 4 to 5, got 3.
      issue = client.issue(board.github_id, number)
      # FIX : Don't work - client.update_issue(board.github_id, number, assignee: github_username)
      client.update_issue(board.github_id, number, issue.title, issue.body, assignee: github_username)
    end

    def update_issue(board, number, issue_params, issue = client.issue(board.github_id, number))
      options = {}
      options[:labels] = issue_params[:labels] if issue_params[:labels]
      client.update_issue(
        board.github_id,
        number,
        issue_params[:title] || issue.title,
        issue_params[:body] || issue.body,
        options
      )
    end

    private

    def find_label_name(board, issue)
      column_names = board.github_labels
      label = issue.labels.detect { |e| column_names.include?(e.name) }
      if label
        label.name
      elsif issue.state == 'open'
        column = board.columns.first
        move_to(board, column, issue.number, issue)
        column.label_name
      end
    end

    def open_issues(board)
      client.issues(board.github_id)
    end

    def closed_issues(board)
      client.issues(board.github_id, state: :closed)
    end
  end
end
