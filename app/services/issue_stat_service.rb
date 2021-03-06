class IssueStatService
  class << self
    def create(board, github_issue)
      issue_stat = build_issue_stat(board, github_issue)
      issue_stat.save!
      issue_stat
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
  end
end
