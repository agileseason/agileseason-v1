class IssuesController < ApplicationController
  # FIX : Need specs.
  before_action :fetch_board, only: [:show, :search, :new]
  before_action :fetch_board_for_update, except: [:show, :search, :new]

  def show
    @direct_post = S3Api.direct_post

    github_issue = github_api.issue(@board, number)
    issue_stat = @board.issue_stats.find_by(number: number)
    @issue = BoardIssue.new(github_issue, issue_stat)
    @labels = @board_bag.labels

    @comments = github_api.issue_comments(@board, @issue.number)
  end

  def search
    issues = github_api.search_issues(@board, params[:query])
    render partial: 'search_result', locals: { issues: issues, board: @board }
  end

  def create
    @issue = Issue.new(issue_params)
    if @issue.valid?
      issue = github_api.create_issue(@board, @issue)
      render(
        partial: 'issues/issue_miniature',
        locals: {
          issue: BoardIssue.new(issue, @board.find_stat(issue)),
          column: @board.columns.first
        }
      )
    else
      render nothing: true
    end
  end

  def update
    github_api.update_issue(
      @board,
      number,
      issue_params
    )

    render nothing: true
  end

  def move_to
    github_api.move_to(@board, @board.columns.find(params[:column_id]), number)
    broadcast

    render json: begin
      Board.includes(columns: :issue_stats).find(@board).columns.map do |column|
        {
          column_id: column.id,
          html: render_to_string(partial: 'columns/wip_badge', locals: { column: column })
        }
      end
    end
  end

  def close
    issue_stat = github_api.close(@board, number)
    respond_to do |format|
      format.html { redirect_to board_url(@board) }
      format.json { render json: { closed: issue_stat.try(:closed?) } }
    end
  end

  def archive
    issue_stat = github_api.archive(@board, number)
    respond_to do |format|
      format.html { redirect_to board_url(@board) }
      format.json do
        render json: {
          column_id: issue_stat.column_id,
          html: render_to_string(
            partial: 'columns/wip_badge.html',
            locals: { column: issue_stat.column }
          )
        }
      end
    end
  end

  def assignee
    issue = github_api.assign(@board, number, login_diff)
    render partial: 'issues/assignee', locals: {
      issue: BoardIssue.new(issue, @board.find_stat(issue))
    }
  end

  def due_date
    due_date_at = params[:due_date].to_datetime # Not to_time, because adding localtime +03

    issue_stat = IssueStatService.set_due_date(
      current_user,
      @board,
      number,
      due_date_at
    )

    render text: k(:issue, issue_stat).due_date_at
  end

  private

  def issue_params
    params
      .require(:issue)
      .permit(:title, :body, labels: [])
  end

  def login_diff
    # FIX : Need issues cache...
    login_prev = github_api.issue(@board, number).try(:assignee).try(:login)
    params[:login] unless login_prev == params[:login]
  end

  def number
    params[:number]
  end

  def broadcast
    FayePusher.broadcast_board(
      current_user,
      @board,
      number: number,
      action: action_name,
      column_id: params[:column_id]
    )
  end
end
