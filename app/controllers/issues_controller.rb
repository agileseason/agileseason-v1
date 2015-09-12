class IssuesController < ApplicationController
  # FIX : Need specs.
  before_action :fetch_board, only: [:show, :search, :new]
  before_action :fetch_board_for_update, except: [:show, :search, :new]

  after_action :fetch_cumulative_graph, only: [
    :create, :move_to, :close, :archive, :unarchive
  ]
  after_action :fetch_lines_graph, only: [:move_to]
  after_action :fetch_control_chart, only: [:close, :reopen]

  def show
    @direct_post = S3Api.direct_post
    @issue = @board_bag.issue(number)
    @comments = issue_comments(@issue)
  end

  def create
    @issue = Issue.new(issue_create_params)
    if @issue.valid?
      issue = github_api.create_issue(@board, @issue)
      ui_event(:issue_create)
      @board_bag.update_cache(issue)
      broadcast_column(@board_bag.default_column)
      render(
        partial: 'issues/issue_miniature',
        locals: {
          issue: BoardIssue.new(issue, @board.find_stat(issue))
        }
      )
    else
      render nothing: true
    end
  end

  def update
    issue = github_api.update_issue(@board, number, issue_update_params)
    @board_bag.update_cache(issue)
    render nothing: true
  end

  def update_labels
    issue = github_api.update_issue(@board, number, issue_labels_params)
    @board_bag.update_cache(issue)
    render nothing: true
  end

  def search
    issues = github_api.search_issues(@board, params[:query])
    ui_event(:issue_search)
    render partial: 'search_result', locals: { issues: issues, board: @board }
  end

  def move_to
    column_to = @board.columns.find(params[:column_id])
    IssueStats::Mover.new(current_user, @board_bag, column_to, number).call
    IssueStats::AutoAssigner.new(current_user, @board_bag, column_to, number).call
    IssueStats::Sorter.new(column_to, number, !!params[:force]).call
    IssueStats::Unready.new(current_user, @board_bag, number).call

    issue_stat = IssueStats::Finder.new(current_user, @board_bag, number).call
    broadcast_column(issue_stat.column)
    broadcast_column(column_to)

    render json: {
      number: number,
      # TODO Remove this element if issue miniature has't been updated - #676
      html_miniature: render_to_string(
        partial: 'issues/issue_miniature',
        locals: { issue: @board_bag.issue(number) }
      ),
      # NOTE Includes(columns: :issue_stats) to remove N+1 query in view 'columns/wip_badge'.
      badges: Board.includes(columns: :issue_stats).find(@board.id).columns.map do |column|
        wip_badge_json(column)
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
    issue_stat = IssueStats::Archiver.new(current_user, @board_bag, number).call
    broadcast_column(issue_stat.column)

    render json: wip_badge_json(issue_stat.column)
  end

  def unarchive
    issue_stat = IssueStatService.unarchive!(@board_bag, number, current_user)
    broadcast_column(issue_stat.column)

    render nothing: true
  end

  def assignee
    issue = github_api.assign(@board, number, params[:login])
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

  def ready
    if params[:issue_stat][:is_ready] == 'true'
      IssueStats::Ready.new(current_user, @board_bag, number).call
    else
      IssueStats::Unready.new(current_user, @board_bag, number).call
    end

    render nothing: true
  end

  private

  def wip_badge_json(column)
    {
      column_id: column.id,
      html: render_to_string(
        partial: 'columns/wip_badge',
        locals: { column: column }
      )
    }
  end

  def issue_create_params
    params.
      require(:issue).
      permit(:title, labels: [])
  end

  def issue_update_params
    params.
      require(:issue).
      permit(:title)
  end

  def issue_labels_params
    # For variant when uncheck all labels
    params[:issue] ||= {}
    params[:issue][:labels] ||= []
    params.
      require(:issue).
      permit(labels: [])
  end

  # TODO Remove this method in #548
  def issue_comments(issue)
    return [] if issue.comments.zero?
    github_api.issue_comments(@board, issue.number)
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
end
