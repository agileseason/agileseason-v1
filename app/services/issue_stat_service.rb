# FIX : Move methods to instance and add user to initializer.
class IssueStatService
  class << self
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
  end
end
