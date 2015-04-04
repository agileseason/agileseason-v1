class IssuesController < ApplicationController
  before_action :fetch_board, only: [:comments]
  before_action :fetch_board_for_update, except: [:comments]

  def show
    github_issue = github_api.issue(@board, params[:number])
    issue_stat = @board.issue_stats.find_by(number: params[:number])
    issue = BoardIssue.new(github_issue, issue_stat)
    render partial: 'issues/issue_modal', locals: { issue: issue, board: @board, labels: @board_bag.labels }
  end

  def new
    @issue = @board_bag.build_issue_new
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

  def comments
    comments = github_api.issue_comments(@board, params[:number].to_i)
    render partial: 'issues/comments', locals: { comments: comments }
  end

  def move_to
    authorize!(:update, @board)
    github_api.move_to(@board, @board.columns.find(params[:column_id]), params[:number])
    render nothing: true
  end

  def close
    issue_stat = github_api.close(@board, params[:number])
    respond_to do |format|
      format.html { redirect_to board_url(@board) }
      format.json { render json: { closed: issue_stat.try(:closed?) } }
    end
  end

  def archive
    issue_stat = github_api.archive(@board, params[:number])
    respond_to do |format|
      format.html { redirect_to board_url(@board) }
      format.json { render json: { archived: issue_stat && issue_stat.archived? } }
    end
  end

  def assignee
    issue = github_api.assign(@board, params[:number], login_diff)
    render partial: 'issues/assignee', locals: {
      issue: BoardIssue.new(issue, @board.find_stat(issue))
    }
  end

  def update
    github_api.update_issue(@board, params[:number],
      body: params[:body],
      title: params[:title],
      labels: params[:labels])
    redirect_to board_url(@board)
  end

  def due_date
    due_date_at = params[:due_date].to_datetime # Not to_time, because adding localtime +03
    issue = @board.issue_stats.find_by(number: params[:number])
    issue.update(due_date_at: due_date_at)
    render text: k(:issue, issue).due_date_at
  end

  private

  def issue_params
    params
      .require(:issue)
      .permit(:title, :body, labels: [])
  end

  def login_diff
    # FIX : Need issues cache...
    login_prev = github_api.issue(@board, params[:number]).try(:assignee).try(:login)
    params[:login] unless login_prev == params[:login]
  end
end
