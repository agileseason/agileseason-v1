class CommentsController < ApplicationController
  before_action :fetch_board

  def index
    comments = Cached::Comments.call(user: current_user, board: @board, number: number)
    sync_comments(comments)

    respond_to do |format|
      format.html do
        render(
          partial: 'comments/show',
          collection: comments,
          as: :comment,
          locals: { board: @board, number: number }
        )
      end
      format.json do
        render json: {
          comments: comments.map { |comment| comment_to_json(comment) }
        }
      end
    end
  end

  def create
    comment = github_api.add_comment(@board, number, comment_body)
    inc_comments_count(1)
    sync_checklist
    ui_event(:issue_comment)
    broadcast(comment)

    respond_to do |format|
      format.html { render partial: 'show', locals: { comment: comment, board: @board, number: number } }
      format.json { render json: { comment: comment_to_json(comment), board_issue: board_issue_json } }
    end
  end

  def update
    comment = github_api.update_comment(@board, id, comment_body)
    sync_checklist
    respond_to do |format|
      format.html { render partial: 'show', locals: { comment: comment, board: @board, number: number } }
      format.json { render json: comment_to_json(comment) }
    end
  end

  def delete
    github_api.delete_comment(@board, id)
    inc_comments_count(-1)
    sync_checklist
    respond_to do |format|
      format.html { render nothing: true }
      format.json { render json: board_issue_json }
    end
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
    return if issue.nil?

    issue.comments += delta
    @board_bag.update_cache(issue)
  end

  def sync_comments(comments)
    return unless can?(:comments, @board_bag)

    sync_checklist(comments)

    issue = @board_bag.issues_hash[number]
    return if issue.nil?

    issue.comments = comments.size
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

  def comment_to_json(comment)
    {
      id: comment.id,
      body: comment.body,
      bodyMarkdown: markdown(comment.body, @board),
      created_at: comment.created_at.strftime('%b %d, %H:%M'),
      user: {
        id: comment.user.id,
        login: comment.user.login,
        avatar_url: comment.user.avatar_url
      }
    }
  end

  # FIX Remove duplication with IssueController
  def board_issue_json
    board_issue = @board_bag.issue(number)
    {
      number: number,
      issue: render_to_string(
        partial: 'issues/issue_miniature',
        locals: { issue: board_issue },
        formats: [:html]
      )
    }
  end
end
