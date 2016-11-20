module BoardIssues
  class DueDatesController < ApplicationController
    include Broadcaster
    include IssueJsonRenderer

    before_action :fetch_board_for_update

    def update
      issue_stat = IssueStats::DueDater.call(
        user: current_user,
        board_bag: @board_bag,
        number: number,
        due_date_at: due_date_at
      )
      broadcast_column(issue_stat.column)
      render_board_issue_json
    end

  private

    def due_date_at
      # Not to_time, because adding localtime +03
      params[:due_date].try(:to_datetime)
    end
  end
end
