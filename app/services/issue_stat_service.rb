# FIX : Move methods to instance and add user to initializer.
class IssueStatService
  class << self
    def create(board, github_issue)
      board.issue_stats.create!(
        number: github_issue.number,
        column: board.default_column,
        created_at: github_issue.created_at,
        updated_at: github_issue.updated_at,
        closed_at: github_issue.closed_at,
      )
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
