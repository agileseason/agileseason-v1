# FIX : Move methods to instance and add user to initializer.
class IssueStatService
  class << self
    def create!(board, github_issue, user)
      column = board.columns.first
      issue_stat = board.issue_stats.create!(
        number: github_issue.number,
        column: column,
        created_at: github_issue.created_at,
        updated_at: github_issue.updated_at,
        closed_at: github_issue.closed_at,
      )

      IssueStats::Sorter.new(column, github_issue.number, true).call
      # TODO Remove move! from here!
      # TODO Call IssueStats::Lifetime
      move!(column, issue_stat, user, force: true)
    end

    def update!(issue_stat, github_issue)
      issue_stat.update(
        created_at: github_issue.created_at,
        updated_at: github_issue.updated_at,
        closed_at: github_issue.closed_at
      )
    end

    # TODO Move to IssueStats::Mover
    def move!(column, issue_stat, user, force = false)
      # TODO Extract IssueStats::ColumnChangeActivity
      if user.present? && issue_stat.column != column
        Activities::ColumnChangedActivity.
          create_for(issue_stat, issue_stat.column, column, user)
      end
      # TODO Extract IssueStats::Lifetime
      issue_stat.update!(column: column)
      leave_all_column(issue_stat)
      issue_stat.lifetimes.create!(
        column: column,
        in_at: Time.current
      )
      issue_stat
    end

    # FIX : Move close! and add close? to state_machine.
    def close!(board, github_issue, user)
      issue_stat = find_or_create_issue_stat(board, github_issue, user)
      issue_stat.update(closed_at: github_issue.closed_at)
      issue_stat
    end

    # FIX : Так же плохо, что код в close, reopen зависит от внешнего кода его вызывающего.
    def reopen!(board, github_issue, user)
      issue_stat = find_or_create_issue_stat(board, github_issue, user)
      issue_stat.update(closed_at: nil)
      issue_stat
    end

    # FIX : Move archive! and archive? to state_machine.
    def archive!(board, github_issue, user)
      issue_stat = find_or_create_issue_stat(board, github_issue, user)
      leave_all_column(issue_stat)
      issue_stat.update!(archived_at: Time.current)
      Activities::ArchiveActivity.create_for(issue_stat, user) if user.present?
      issue_stat
    end

    def unarchive!(board, number, user)
      issue_stat = find(board, number)
      return unless issue_stat.archive?

      Activities::UnarchiveActivity.create_for(issue_stat, user)
      move!(issue_stat.column, issue_stat, user, true)
      issue_stat.update!(archived_at: nil)
      issue_stat
    end

    def archived?(board, number)
      board.issue_stats.find_by(number: number).try(:archived?)
    end

    def find_or_create_issue_stat(board, github_issue, user)
      find(board, github_issue.number) || create!(board, github_issue, user)
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
