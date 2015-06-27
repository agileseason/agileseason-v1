class CommentsController < ApplicationController
  # FIX : Need specs.
  before_action :fetch_board_for_update, except: [:index]
  before_action :fetch_board, only: [:index]

  def create
    comment = github_api.add_comment(@board, number, params[:comment][:body])
    broadcast(:create, comment)
    render partial: 'show', locals: { comment: comment, board: @board }
  end

  def update
    comment = github_api.update_comment(@board, number, params[:comment][:body])
    render partial: 'show', locals: { comment: comment, board: @board }
  end

  def delete
    github_api.delete_comment(@board, number)
    render nothing: true
  end

  private

  def number
    params[:number]
  end

  def broadcast(action, comment)
    FayePusher.broadcast_issue(
      current_user,
      @board,
      action: action,
      number: number,
      html: render_to_string(partial: 'show', locals: { comment: comment, board: @board })
    )
  end
end
