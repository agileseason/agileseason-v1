module Graphs
  class IssueStatsWorker < BaseWorker
    AUTO_ARCHIVE_BOUND = 3.month.ago

    def perform(board_id, encrypted_github_token)
      @board = Board.find(board_id)
      issues = fetch_issues_to_sync(encrypted_github_token)
      create_issue_stats(issues)
      update_issue_stats(issues)
      auto_archive_issue_stats(issues)
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
        next if issue_stat.nil? || issue_stat.updated_at.to_i == issue.updated_at.to_i

        sync_issue_stat(issue_stat, issue)
      end
    end

    def last_number
      @last_number ||= @board.issue_stats.maximum(:number).to_i
    end

    # TODO Нужно делать не так, а архивировать закрытые, которых нет уже на доске.
    def auto_archive_issue_stats(issues)
      old_closed_numbers = issues.
        select { |issue| issue.state == 'closed' && issue.closed_at < AUTO_ARCHIVE_BOUND }.
        map(&:number)

      # TODO Create activities for auto-archived issues.
      # NOTE Try create Agile Season user with id = 0 and create activity from him.
      @board.issue_stats.
        visible.
        where(number: old_closed_numbers).
        update_all(archived_at: Time.current)
    end

    def sync_issue_stat(issue_stat, github_issue)
      issue_stat.update!(
        created_at: github_issue.created_at,
        updated_at: github_issue.updated_at,
        closed_at: github_issue.closed_at
      )
    end
  end
end
