class IssuesController < ApplicationController
  READ_ACTION = [:show, :new, :search, :modal_data].freeze
  # FIX : Need specs.
  before_action :fetch_board, only: READ_ACTION
  before_action :fetch_board_for_update, except: READ_ACTION

  after_action :fetch_cumulative_graph, only: [:create, :move_to, :archive, :unarchive]
  after_action :fetch_lines_graph, only: [:move_to]
  after_action :fetch_control_chart, only: [:close, :reopen]

  def show
    respond_to do |format|
      format.html { redirect_to un(board_url(@board, number: number)) }
      format.json do
        @issue = @board_bag.issue(number)
        render json: @issue.to_hash
      end
    end
  end

  def create
    @issue = Issue.new(issue_create_params)
    if @issue.valid?
      board_issue = IssueStats::Creator.new(current_user, @board_bag, @issue).call
      ui_event(:issue_create)
      broadcast_column(board_issue.column)
      render(partial: 'issue_miniature', locals: { issue: board_issue })
    else
      render nothing: true
    end
  end

  def update
    issue = github_api.update_issue(@board, number, issue_update_params)
    @board_bag.update_cache(issue)
    respond_to do |format|
      format.html { render nothing: true }
      format.json { render_board_issue_json }
    end
  end

  def update_labels
    issue = github_api.update_issue(@board, number, issue_labels_params)
    @board_bag.update_cache(issue)
    respond_to do |format|
      format.html { render nothing: true }
      format.json { render_board_issue_json }
    end
  end

  def modal_data
    render json: k(:issue, @board_bag.issue(number)).to_hash(@board_bag)
  end

  def search
    issues = github_api.search_issues(@board, params[:query])
    ui_event(:issue_search)
    render partial: 'search_result', locals: { issues: issues, board: @board }
  end

  def move_to
    issue_stat = IssueStats::Finder.new(current_user, @board_bag, number).call

    column_to = @board.columns.find(params[:column_id])
    column_from = issue_stat.column

    IssueStats::Mover.call(
      user: current_user,
      board_bag: @board_bag,
      column_to: column_to,
      number: number,
      is_force_sort: !!params[:force]
    )

    broadcast_column(column_from, params[:force])
    broadcast_column(column_to, params[:force])

    issue_stat.reload
    render json: {
      # NOTE Includes(:issue_stats) to remove N+1 query in view 'columns/wip_badge'.
      badges: Column.includes(:issue_stats).where(board_id: @board.id).map do |column|
        wip_badge_json(column)
      end
    }
  end

  def close
    issue_stat = IssueStats::Closer.call(user: current_user, board_bag: @board_bag, number: number)
    broadcast_column(issue_stat.column)

    respond_to do |format|
      format.html { render nothing: true }
      format.json { render_board_issue_json }
    end
  end

  def reopen
    issue_stat = IssueStats::Reopener.new(current_user, @board_bag, number).call
    broadcast_column(issue_stat.column)

    respond_to do |format|
      format.html { render nothing: true }
      format.json { render_board_issue_json }
    end
  end

  def archive
    issue_stat = IssueStats::Archiver.new(current_user, @board_bag, number).call
    broadcast_column(issue_stat.column)

    respond_to do |format|
      format.html { render json: wip_badge_json(issue_stat.column) }
      format.json { render_board_issue_json }
    end
  end

  def unarchive
    issue_stat = IssueStats::Unarchiver.new(current_user, @board_bag, number).call
    # NOTE Use force because there is no div#issue-n to update.
    broadcast_column(issue_stat.column, true)

    respond_to do |format|
      format.html { render nothing: true }
      format.json { render_board_issue_json }
    end
  end

  def assignee
    IssueStats::Assigner.new(
      current_user,
      @board_bag,
      number,
      params[:login]
    ).call

    respond_to do |format|
      format.json { render_board_issue_json }
    end
  end

  def due_date
    due_date_at = params[:due_date].try(:to_datetime) # Not to_time, because adding localtime +03

    issue_stat = IssueStatService.set_due_date(
      current_user,
      @board,
      number,
      due_date_at
    )

    respond_to do |format|
      format.html { render text: k(:issue, issue_stat).due_date_at }
      format.json { render_board_issue_json }
    end
  end

  def toggle_ready
    issue_stat = IssueStats::Finder.new(current_user, @board_bag, number).call
    if issue_stat.ready?
      IssueStats::Unready.call(user: current_user, board_bag: @board_bag, number: number)
    else
      IssueStats::Ready.call(user: current_user, board_bag: @board_bag, number: number)
    end
    broadcast_column(issue_stat.column)

    respond_to do |format|
      format.html { render nothing: true }
      format.json { render_board_issue_json }
    end
  end

  def fetch_miniature
    render_board_issue_json
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

  def fetch_cumulative_graph
    Graphs::CumulativeWorker.perform_async(@board.id, encrypted_github_token)
  end

  def fetch_control_chart
    Graphs::IssueStatsWorker.perform_async(@board.id, encrypted_github_token)
  end

  def fetch_lines_graph
    Graphs::LinesWorker.perform_async(@board.id, encrypted_github_token)
  end

  def render_board_issue_json
    board_issue = @board_bag.issue(number)
    render json: {
      number: number,
      issue: render_to_string(
        partial: 'issue_miniature',
        locals: { issue: board_issue },
        formats: [:html]
      )
    }
  end
end
