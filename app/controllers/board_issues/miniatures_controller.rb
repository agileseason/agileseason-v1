module BoardIssues
  class MiniaturesController < ApplicationController
    include IssueJsonRenderer

    before_action :fetch_board_for_update

    def show
      render_board_issue_json
    end
  end
end
