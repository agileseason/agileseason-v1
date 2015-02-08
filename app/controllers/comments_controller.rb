class CommentsController < ApplicationController
  before_action :fetch_board

  def create
    github_api.add_comment(@board, params[:number], params[:comment])
    render nothing: true
  end

  def update
    github_api.update_comment(@board, params[:number], params[:comment])
    render nothing: true
  end
end
