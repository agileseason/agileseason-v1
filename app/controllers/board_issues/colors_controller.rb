module BoardIssues
  class ColorsController < ApplicationController
    include Broadcaster
    include IssueJsonRenderer

    before_action :fetch_board_for_update

    def update
      issue_stat = IssueStats::Painter.call(
        user: current_user,
        board_bag: @board_bag,
        number: number,
        color: params[:issue][:color]
      )
      broadcast_column(issue_stat.column)
      render_board_issue_json
    end
  end
end
