class CommentsController < ApplicationController
  # FIX : Need specs.
  before_action :fetch_board, only: [:index]
  before_action :fetch_board_for_update, except: [:index]
  after_action :fetch_issue, only: [:create, :delete]

  def index
    comments = github_api.issue_comments(@board, number)
    render(
      partial: 'comments/show',
      collection: comments,
      as: :comment,
      locals: { board: @board, number: number }
    )
  end

  def create
    comment = github_api.add_comment(@board, number, comment_body)
    sync_checklist
    ui_event(:issue_comment)
    broadcast(comment)
    render partial: 'show', locals: { comment: comment, board: @board, number: number }
  end

  def update
    comment = github_api.update_comment(@board, id, comment_body)
    sync_checklist
    render partial: 'show', locals: { comment: comment, board: @board, number: number }
  end

  def delete
    github_api.delete_comment(@board, id)
    sync_checklist
    render nothing: true
  end

  private

  def comment_body
    params[:comment][:body]
  end

  def id
    params[:id].to_i
  end

  def broadcast(comment)
    FayePusher.broadcast_issue(
      current_user,
      @board,
      action: "comment_#{action_name}",
      number: number,
      html: render_to_string(
        partial: 'show',
        locals: { comment: comment, board: @board, number: number }
      )
    )
  end

  def fetch_issue
    issue = @board_bag.issues_hash[number]
    return unless issue

    if action_name == 'create'
      issue.comments += 1
    else
      issue.comments -= 1
    end
    @board_bag.update_cache(issue)
  end

  def sync_checklist
    IssueStats::SyncChecklist.call(
      user: current_user,
      board_bag: @board_bag,
      number: number
    )
  end
end
