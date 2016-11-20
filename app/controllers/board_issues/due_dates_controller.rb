module BoardIssues
  class DueDatesController < ApplicationController
    include Broadcaster
    include IssueJsonRenderer

    before_action :fetch_board_for_update

    def update
      # Not to_time, because adding localtime +03
      due_date_at = params[:due_date].try(:to_datetime)

      issue_stat = IssueStatService.set_due_date(
        current_user,
        @board,
        number,
        due_date_at
      )
      broadcast_column(issue_stat.column)

      render_board_issue_json
    end
  end
end
