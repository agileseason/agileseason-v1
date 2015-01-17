module Graphs
  class IssueStatsWorker < BaseWorker
    def perform(board_id, github_token)
      @board = Board.find(board_id)
      issues = fetch_issues_to_sync(github_token)
      create_issue_stats(issues)
      update_issue_stats(issues)
    end

    private

    def fetch_issues_to_sync(github_token)
      issues = GithubApi.new(github_token).issues(@board)
      issues.select { |issue| issue.state == 'open' || issue.created_at >= @board.created_at }
    end

    def create_issue_stats(issues)
      new_issues = issues.select { |issue| issue.number > last_number }
      new_issues.each do |issue|
        @board.issue_stats.create!(
          number: issue.number,
          created_at: issue.created_at,
          updated_at: issue.updated_at,
          closed_at: issue.closed_at
        )
      end
    end

    def update_issue_stats(issues)
      issues_to_update = issues.select { |issue| issue.number <= last_number }
      issues_to_update.each do |issue|
        issue_stat = @board.issue_stats.find_by(number: issue.number)
        next if !issue_stat || issue_stat.updated_at.to_i == issue.updated_at.to_i
        issue_stat.update(
          created_at: issue.created_at,
          updated_at: issue.updated_at,
          closed_at: issue.closed_at
        )
      end
    end

    def last_number
      @board.issue_stats.maximum(:number).to_i
    end
  end
end
