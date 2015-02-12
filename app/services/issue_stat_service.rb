class IssueStatService
  class << self
    def create!(board, github_issue)
      issue_stat = board.issue_stats.create!(
        number: github_issue.number,
        column: board.columns.first,
        created_at: github_issue.created_at,
        updated_at: github_issue.updated_at,
        closed_at: github_issue.closed_at,
      )
      issue_stat.lifetimes.create!(
        column: board.columns.first,
        in_at: Time.current,
      )
      issue_stat
    end

    def update!(issue_stat, github_issue)
      issue_stat.update(
        created_at: github_issue.created_at,
        updated_at: github_issue.updated_at,
        closed_at: github_issue.closed_at
      )
    end

    def move!(board, column, github_issue)
      issue_stat = find_or_create_issue_stat(board, github_issue)
      issue_stat.update!(column: column)
      leave_all_column(issue_stat)
      issue_stat.lifetimes.create!(
        column: column,
        in_at: Time.current
      )
      issue_stat
    end

    # FIX : Move close! and add close? to state_machine.
    def close!(board, github_issue)
      issue_stat = find_or_create_issue_stat(board, github_issue)
      issue_stat.update(closed_at: (github_issue.closed_at || Time.current))
      issue_stat
    end

    # FIX : Move archive! and archive? to state_machine.
    def archive!(board, github_issue)
      issue_stat = find_or_create_issue_stat(board, github_issue)
      leave_all_column(issue_stat)
      issue_stat.update!(archived_at: Time.current)
      issue_stat
    end

    def archived?(board, number)
      board.issue_stats.find_by(number: number).try(:archived?)
    end

    private

    def find_or_create_issue_stat(board, github_issue)
      board.issue_stats.find_by(number: github_issue.number) || create!(board, github_issue)
    end

    def leave_all_column(issue_stat)
      issue_stat.lifetimes.update_all(out_at: Time.current)
    end
  end
end
