module BoardIssues
  class AssigneesController < ApplicationController
    include IssueJsonRenderer

    before_action :fetch_board_for_update

    def update
      IssueStats::Assigner.call(
        user: current_user,
        board_bag: @board_bag,
        number: number,
        login: params[:login]
      )

      render_board_issue_json
    end
  end
end
