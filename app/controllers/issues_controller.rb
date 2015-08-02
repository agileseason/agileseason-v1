class IssuesController < ApplicationController
  # FIX : Need specs.
  before_action :fetch_board, only: [:show, :search, :new]
  before_action :fetch_board_for_update, except: [:show, :search, :new]

  after_action :fetch_cumulative_graph, only: [
    :move_to, :close, :archive, :unarchive
  ]
  after_action :fetch_lines_graph, only: [:move_to]
  after_action :fetch_control_chart, only: [:close, :reopen]

  def show
    @direct_post = S3Api.direct_post
    @issue = BoardIssue.new(
      github_issue,
      IssueStatService.find_or_build_issue_stat(@board, github_issue)
    )
    # TODO : Find a way to accelerate this request.
    @comments = github_api.issue_comments(@board, number)
  end

  def search
    ui_event(:issue_search)
    issues = github_api.search_issues(@board, params[:query])
    render partial: 'search_result', locals: { issues: issues, board: @board }
  end

  def create
    @issue = Issue.new(issue_params)
    if @issue.valid?
      ui_event(:issue_create)
      issue = github_api.create_issue(@board, @issue)
      @board_bag.update_cache(issue)
      render(
        partial: 'issues/issue_miniature',
        locals: {
          issue: BoardIssue.new(issue, @board.find_stat(issue)),
          column: @board_bag.default_column
        }
      )
      broadcast_column(@board_bag.default_column)
    else
      render nothing: true
    end
  end

  def update
    update_issue(issue_params)
    render nothing: true
  end

  def update_labels
    update_issue(issue_labels_params)
    render nothing: true
  end

  def move_to
    column_from = IssueStatService.find(@board, number).try(:column)
    column_to = @board.columns.find(params[:column_id])
    issue_stat = github_api.move_to(@board, column_to, number, force?)

    if column_to.auto_assign? && github_issue.assignee.nil?
      issue = github_api.assign(@board, number, current_user.github_username)
      @board_bag.update_cache(issue)
    end

    if force?
      broadcast_column(column_from) if column_from
      broadcast_column(issue_stat.column)
    end

    render json: {
      number: number,
      html_miniature: render_to_string(
        partial: 'issues/issue_miniature',
        locals: { issue: BoardIssue.new(issue || github_issue, issue_stat), column: column_to }
      ),
      badges: Board.includes(columns: :issue_stats).find(@board.id).columns.map do |column|
        {
          column_id: column.id,
          html: render_to_string(partial: 'columns/wip_badge', locals: { column: column })
        }
      end
    }
  end

  def close
    board_issue = github_api.close(@board, number)
    @board_bag.update_cache(board_issue.issue)
    broadcast_column(board_issue.column)

    render nothing: true
  end

  def reopen
    board_issue = github_api.reopen(@board, number)
    @board_bag.update_cache(board_issue.issue)
    broadcast_column(board_issue.column)

    render nothing: true
  end

  def archive
    board_issue = github_api.archive(@board, number)
    @board_bag.update_cache(board_issue.issue)
    broadcast_column(board_issue.column)

    render json: {
      column_id: board_issue.column_id,
      html: render_to_string(
        partial: 'columns/wip_badge.html',
        locals: { column: board_issue.column }
      )
    }
  end

  def unarchive
    issue_stat = IssueStatService.unarchive!(@board_bag, number, current_user)
    broadcast_column(issue_stat.column)

    render nothing: true
  end

  def assignee
    issue = github_api.assign(@board, number, login_diff)
    @board_bag.update_cache(issue)

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

  def github_issue
    @github_issue ||= @board_bag.issues_hash[number] || github_api.issue(@board, number)
  end

  def update_issue(issue_params)
    issue = github_api.update_issue(
      @board,
      number,
      issue_params
    )
    @board_bag.update_cache(issue)
  end

  def issue_params
    params.
      require(:issue).
      permit(:title, :body)
  end

  def issue_labels_params
    # For variant when uncheck all labels
    params[:issue] ||= {}
    params[:issue][:labels] ||= []
    params.
      require(:issue).
      permit(labels: [])
  end

  def login_diff
    # FIX : Need issues cache...
    login_prev = github_api.issue(@board, number).try(:assignee).try(:login)
    params[:login] unless login_prev == params[:login]
  end

  def number
    params[:number].to_i
  end

  def fetch_cumulative_graph
    Graphs::CumulativeWorker.perform_async(@board.id, encrypted_github_token)
  end

  def fetch_control_chart
    Graphs::IssueStatsWorker.perform_async(@board.id, encrypted_github_token)
  end

  def fetch_lines_graph
    Graphs::LinesWorker.perform_async(@board.id, encrypted_github_token)
  end

  def force?
    !!params[:force]
  end
end
