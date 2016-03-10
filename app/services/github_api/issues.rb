class GithubApi
  module Issues
    ALLOWED_EVENTS = ['closed', 'reopened'].freeze

    def issues(board)
      (open_issues(board) + closed_issues(board))
        .reject(&:pull_request)
    end

    def create_issue(board, issue)
      client.create_issue(
        board.github_id,
        issue.title,
        issue.body,
        labels: issue.labels
      )
    end

    def issue(board, number)
      client.issue(board.github_id, number)
    end

    def close(board, number)
      client.close_issue(board.github_id, number)
    end

    def reopen(board, number)
      client.reopen_issue(board.github_id, number)
    end

    def assign(board, number, assignee)
      issue = issue(board, number)
      # TODO Remove current_assignee and logic with nil if eq.
      current_assignee = issue.try(:assignee).try(:login)
      assignee = nil if current_assignee == assignee
      # NOTE client.update_issue(board.github_id, number, assignee: github_username) doesn't work
      client.update_issue(board.github_id, number, issue.title, issue.body, assignee: assignee)
    end

    def update_issue(board, number, issue_params, issue = issue(board, number))
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

    def search_issues(board, query)
      client.search_issues(
        "#{query.gsub('@', 'assignee:')} type:issue repo:#{board.github_full_name}"
      ).items
    end

    def issue_events(board, number)
      client.issue_events(board.github_id, number).
        select { |e| ALLOWED_EVENTS.include?(e.event) }
    end

    private

    def open_issues(board)
      client.issues(board.github_id)
    end

    # FIX : Think about this - since: ... (added after cache problem)
    # NOTE : Reason missed issues and broken CFD.
    def closed_issues(board)
      client.issues(board.github_id, state: :closed, since: 2.month.ago.iso8601)
    end
  end
end
