class IssuesController < ApplicationController
  before_action :fetch_board

  def new
    @issue = Issue.new
  end

  def create
    @issue = Issue.new(issue_params)
    if @issue.valid?
      github_api.create_issue(@board, @issue)
      redirect_to board_url(@board)
    else
      render 'new'
    end
  end

  def move_to
    github_api.move_to(@board, @board.columns.find(params[:column_id]), params[:number])
    redirect_to board_url(@board)
  end

  private

  def issue_params
    params
      .require(:issue)
      .permit(:title, :body)
  end

  def fetch_board
    @board = current_user.boards.find(params[:board_id])
  end
end
