class IssuesController < ApplicationController
  include Broadcaster
  include IssueJsonRenderer

  READ_ACTION = [:show, :new].freeze
  # FIX : Need specs.
  before_action :fetch_board, only: READ_ACTION
  before_action :fetch_board_for_update, except: READ_ACTION

  after_action :fetch_cumulative_graph, only: [:create]

  def show
    respond_to do |format|
      format.html { redirect_to un(board_url(@board, number: number)) }
      format.json do
        @issue = @board_bag.issue(number)
        render json: @issue.to_hash
      end
    end
  end

  def create
    # NOTE : to_h fixed DEPRECATION WARNING: Method to_hash is deprecated
    #        and will be removed in Rails 5.1
    @issue = Issue.new(issue_create_params.to_h)
    if @issue.valid?
      board_issue = IssueStats::Creator.new(current_user, @board_bag, @issue).call
      ui_event(:issue_create)
      broadcast_column(board_issue.column)
      render(json: {
        html: render_to_string(partial: 'issue_miniature',
          locals: { issue: board_issue })
      })
    else
      head :ok
    end
  end

  def update
    issue = github_api.update_issue(@board, number, issue_update_params.to_h)
    @board_bag.update_cache(issue)
    respond_to do |format|
      format.html { head :ok }
      format.json { render_board_issue_json }
    end
  end

private

  def issue_create_params
    params.require(:issue).permit(:title, :color, :column_id, labels: [])
  end

  def issue_update_params
    params.require(:issue).permit(:title)
  end

  # TODO: Remove this method after finish refactoring - CumulativeGraphUpdater.
  def fetch_cumulative_graph
    Graphs::CumulativeWorker.perform_async(@board.id, encrypted_github_token)
  end
end
