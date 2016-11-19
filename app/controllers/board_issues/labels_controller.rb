module BoardIssues
  class LabelsController < ApplicationController
    include IssueJsonRenderer

    before_action :fetch_board_for_update

    def update
      issue = github_api.update_issue(@board, number, labels_params.to_h)
      @board_bag.update_cache(issue)
      respond_to do |format|
        format.html { head :ok }
        format.json { render_board_issue_json }
      end
    end

  private

    def labels_params
      # For variant when uncheck all labels
      params[:issue] ||= {}
      params[:issue][:labels] ||= []

      params.
        require(:issue).
        permit(labels: [])
    end
  end
end
