# FIX : Move methods to instance and add user to initializer.
class IssueStatService
  class << self
    def create!(board, github_issue)
      column = board.columns.first
      issue_stat = board.issue_stats.create!(
        number: github_issue.number,
        column: column,
        created_at: github_issue.created_at,
        updated_at: github_issue.updated_at,
        closed_at: github_issue.closed_at,
      )

      issue_stat.lifetimes.create!(
        column: column,
        in_at: Time.current,
      )

      column.update(issues: column.issues.unshift(github_issue.number.to_s))

      issue_stat
    end

    def update!(issue_stat, github_issue)
      issue_stat.update(
        created_at: github_issue.created_at,
        updated_at: github_issue.updated_at,
        closed_at: github_issue.closed_at
      )
    end

    def move!(user, column, issue_stat)
      if issue_stat.column != column
        issue_stat.update!(column: column)
        leave_all_column(issue_stat)
        issue_stat.lifetimes.create!(
          column: column,
          in_at: Time.current
        )
        # FIX : Save info about previous column after #126
        Activities::ColumnChangedActivity.create_for(issue_stat, nil, column, user)
      end
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

    def find_or_create_issue_stat(board, github_issue)
      find(board, github_issue.number) || create!(board, github_issue)
    end

    def find_or_build_issue_stat(board, github_issue)
      issue_stat = find(board, github_issue.number)
      if issue_stat.nil?
        issue_stat = board.issue_stats.build(
          number: github_issue.number,
          created_at: github_issue.created_at,
          updated_at: github_issue.updated_at,
          closed_at: github_issue.closed_at,
        )
      end

      issue_stat
    end

    def find(board, number)
      board.issue_stats.find_by(number: number)
    end

    def set_due_date(user, board, number, due_date_at)
      issue_stat = find(board, number)
      issue_stat.update(due_date_at: due_date_at)
      Activities::ChangeDueDate.create_for(issue_stat, user)
      issue_stat
    end

    private

    def leave_all_column(issue_stat)
      issue_stat.lifetimes.update_all(out_at: Time.current)
    end
  end
end
