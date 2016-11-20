module BoardIssues
  class SearchesController < ApplicationController
    before_action :fetch_board

    def show
      issues = github_api.search_issues(@board, params[:query])
      ui_event(:issue_search)
      render partial: 'issues/search_result', locals: { issues: issues, board: @board }
    end
  end
end
