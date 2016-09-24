class CommentsController < ApplicationController
  before_action :fetch_board

  def index
    # FIX Return Modal::Comment form Modal::CommentsFetcher <= Cached::Comments.call
    comments = Cached::Comments.call(
      user: current_user,
      board: @board,
      number: number
    )
    sync_comments(comments)

    render json: { comments: comments_items(comments) }
  end

  def create
    comment = github_api.add_comment(@board, number, comment_body)
    inc_comments_count(1)
    sync_checklist
    ui_event(:issue_comment)

    respond_to do |format|
      format.json do
        render json: {
          comment: comment_to_json(comment), board_issue: board_issue_json
        }
      end
    end
  end

  def update
    comment = github_api.update_comment(@board, id, comment_body)
    sync_checklist
    respond_to do |format|
      format.json { render json: comment_to_json(comment) }
    end
  end

  def delete
    github_api.delete_comment(@board, id)
    inc_comments_count(-1)
    sync_checklist
    respond_to do |format|
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
      CheckboxSynchronizer.perform_async(@board.id, number,
        encrypted_github_token)
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
    Modal::Comment.new(comment, markdown(comment.body, @board)).to_h
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

  def comments_items(github_comments)
    events = Modal::EventsFetcher.call(
      user: current_user,
      board_bag: @board_bag,
      number: number
    )
    comments = github_comments.map do |comment|
      Modal::Comment.new(comment, markdown(comment.body, @board))
    end

    (events + comments).sort_by(&:created_at).map(&:to_h)
  end
end
