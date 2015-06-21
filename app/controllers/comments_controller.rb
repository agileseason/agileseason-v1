class CommentsController < ApplicationController
  # FIX : Need specs.
  before_action :fetch_board_for_update, except: [:index]
  before_action :fetch_board, only: [:index]

  #def index
    #comments = github_api.issue_comments(@board, params[:number])
    #render partial: 'index', locals: { comments: comments, board: @board }
  #end

  def create
    comment = github_api.add_comment(@board, params[:number], params[:comment][:body])
    render partial: 'show', locals: { comment: comment, board: @board }
  end

  def update
    comment = github_api.update_comment(@board, params[:number], params[:comment][:body])
    render partial: 'show', locals: { comment: comment, board: @board }
  end

  def delete
    github_api.delete_comment(@board, params[:number])
    render nothing: true
  end
end
