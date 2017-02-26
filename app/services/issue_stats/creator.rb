module IssueStats
  class Creator
    pattr_initialize :user, :board_bag, :issue_info

    def call
      create_issue
      assign_issue
      sort_issue

      BoardIssue.new(@github_issue, @issue_stat)
    end

  private

    def create_issue
      @github_issue = user.github_api.create_issue(board_bag, issue_info)
      @issue_stat = create_issue_stat
      board_bag.update_cache(@github_issue)
    end

    def assign_issue
      updated_github_issue = IssueStats::AutoAssigner.call(
        user: user,
        board_bag: board_bag,
        column: @issue_stat.column,
        number: @issue_stat.number
      )
      @github_issue = updated_github_issue if updated_github_issue.present?
    end

    def sort_issue
      IssueStats::Sorter.call(
        column_to: @issue_stat.column,
        number: @issue_stat.number,
        is_force_sort: true
      )
    end

    def create_issue_stat
      issue_stat = IssueStatService.build_issue_stat(board_bag,
        @github_issue)
      issue_stat.column = column
      issue_stat.save!

      issue_stat = IssueStats::Painter.call(
        user: user,
        board_bag: board_bag,
        number: issue_stat.number,
        color: issue_info.color
      )
      issue_stat
    end

    def column
      return board_bag.default_column if issue_info.column_id.nil?
      board_bag.columns.find(issue_info.column_id)
    end
  end
end
