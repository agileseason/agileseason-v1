module BoardIssues
  class ModalsController < ApplicationController
    include IssueJsonRenderer

    before_action :fetch_board

    def show
      render json: k(:issue, @board_bag.issue(number)).to_hash(@board_bag)
    end
  end
end
