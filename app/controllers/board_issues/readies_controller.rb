module BoardIssues
  class ReadiesController < ApplicationController
    include Broadcaster
    include IssueJsonRenderer

    before_action :fetch_board_for_update

    def update
      if issue_stat.ready?
        IssueStats::Unready.call(user: current_user, board_bag: @board_bag,
          number: number)
      else
        IssueStats::Ready.call(user: current_user, board_bag: @board_bag,
          number: number)
      end
      broadcast_column(issue_stat.column)
      render_board_issue_json
    end

  private

    def issue_stat
      issue_stat = IssueStats::Finder.new(current_user, @board_bag, number).call
    end
  end
end
