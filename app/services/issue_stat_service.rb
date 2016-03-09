# FIX : Move methods to instance and add user to initializer.
class IssueStatService
  class << self
    def create(board, github_issue)
      build_issue_stat(board, github_issue).save!
    end

    def find_or_build_issue_stat(board, github_issue)
      issue_stat = find(board, github_issue.number)
      issue_stat || build_issue_stat(board, github_issue)
    end

    def find(board, number)
      board.issue_stats.find_by(number: number)
    end

    def build_issue_stat(board, github_issue)
      board.issue_stats.build(
        number: github_issue.number,
        column: board.default_column,
        created_at: github_issue.created_at,
        updated_at: github_issue.updated_at,
        closed_at: github_issue.closed_at,
      )
    end

    def set_due_date(user, board, number, due_date_at)
      issue_stat = find(board, number)
      issue_stat.update(due_date_at: due_date_at)
      Activities::ChangeDueDate.create_for(issue_stat, user)
      issue_stat
    end
  end
end
