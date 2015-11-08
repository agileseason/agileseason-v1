class CommentsController < ApplicationController
  before_action :fetch_board

  def index
    comments = github_api.issue_comments(@board, number)
    sync_checklist(comments)
    render(
      partial: 'comments/show',
      collection: comments,
      as: :comment,
      locals: { board: @board, number: number }
    )
  end

  def create
    comment = github_api.add_comment(@board, number, comment_body)
    inc_comments_count(1)
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
    inc_comments_count(-1)
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

  def inc_comments_count(delta)
    issue = @board_bag.issues_hash[number]
    return unless issue

    issue.comments += delta
    @board_bag.update_cache(issue)
  end

  def sync_checklist(comments = nil)
    if comments.nil?
      CheckboxSynchronizer.perform_async(@board.id, number, encrypted_github_token)
    else
      IssueStats::LazySyncChecklist.call(
        user: current_user,
        board_bag: @board_bag,
        number: number,
        comments: comments
      )
    end
  end
end
