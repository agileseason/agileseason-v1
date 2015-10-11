module Graphs
  class IssueStatsWorker < BaseWorker
    SYNCED_FIELDS = [:created_at, :closed_at].freeze

    def perform(board_id, encrypted_github_token)
      @board = Board.find(board_id)
      issues = fetch_issues_to_sync(encrypted_github_token)
      create_issue_stats(issues)
      update_issue_stats(issues)
    end

    private

    def fetch_issues_to_sync(encrypted_github_token)
      issues = github_api(encrypted_github_token).issues(@board)
      issues.select { |issue| issue.state == 'open' || issue.created_at >= @board.created_at }
    end

    def create_issue_stats(issues)
      new_issues = issues.select { |issue| issue.number > last_number }
      new_issues.each { |issue| IssueStatService.create(@board, issue) }
    end

    def update_issue_stats(issues)
      issues_to_update = issues.select { |issue| issue.number <= last_number }
      issues_to_update.each do |issue|
        issue_stat = @board.issue_stats.find_by(number: issue.number)
        if update_required?(issue_stat, issue)
          sync_issue_stat(issue_stat, issue)
        end
      end
    end

    def last_number
      @last_number ||= @board.issue_stats.maximum(:number).to_i
    end

    def sync_issue_stat(issue_stat, github_issue)
      SYNCED_FIELDS.each do |field|
        issue_stat.public_send("#{field}=", github_issue.public_send(field))
      end
      issue_stat.save!
    end

    def update_required?(issue_stat, issue)
      issue_stat.present? &&
        issue_stat.closed_at != issue.closed_at
    end
  end
end
