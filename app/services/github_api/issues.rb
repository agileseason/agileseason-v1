class GithubApi
  module Issues
    def issues(board)
      (open_issues(board) + closed_issues(board))
        .select { |issue| !issue.pull_request }
        .sort { |a, b| b.updated_at <=> a.updated_at }
    end

    def create_issue(board, issue)
      github_issue = client.create_issue(
        board.github_id,
        issue.title,
        issue.body,
        labels: issue.labels
      )
      IssueStatService.create!(board, github_issue, @user)
      github_issue
    end

    def issue(board, number)
      client.issue(board.github_id, number)
    end

    def move_to(board, column, number, force = false)
      issue_stat = IssueStatService.find(board, number) ||
                   IssueStatService.create!(board, issue(board, number), @user)
      IssueStatService.move!(column, issue_stat, @user, force)
    end

    def close(board, number)
      github_issue = client.close_issue(board.github_id, number)
      IssueStatService.close!(board, github_issue, @user)
      github_issue
    end

    def archive(board, number)
      issue = issue(board, number)
      IssueStatService.archive!(board, issue, @user) if issue.state == 'closed'
      issue
    end

    def assign(board, number, github_username)
      # FIX : Get issue - don't work override, error: Wrong number of arguments. Expected 4 to 5, got 3.
      issue = issue(board, number)
      # FIX : Don't work - client.update_issue(board.github_id, number, assignee: github_username)
      client.update_issue(board.github_id, number, issue.title, issue.body, assignee: github_username)
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

    private

    def open_issues(board)
      client.issues(board.github_id)
    end

    # FIX : Think about this - since: ... (added after cache problem)
    # UPDATE 1 : Add dalli compress: true and change 1.month to 2.month.ago.
    def closed_issues(board)
      client.issues(board.github_id, state: :closed, since: 2.month.ago.iso8601)
    end
  end
end
