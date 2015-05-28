class CommentsController < ApplicationController
  # FIX : Need specs.
  before_action :fetch_board_for_update, except: [:index]
  before_action :fetch_board, only: [:index]

  def index
    comments = github_api.issue_comments(@board, params[:number])
    render partial: 'index', locals: { comments: comments, board: @board }
  end

  def create
    github_api.add_comment(@board, params[:number], params[:comment])
    render nothing: true
  end

  def update
    github_api.update_comment(@board, params[:number], params[:comment])
    render nothing: true
  end

  def delete
    github_api.delete_comment(@board, params[:number])
    render nothing: true
  end
end
