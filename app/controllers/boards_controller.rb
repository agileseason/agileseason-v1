class BoardsController < ApplicationController
  after_action :fetch_repo_history, only: :show
  before_action :fetch_board, only: [:show, :destroy]
  before_action :check_permissions, only: :create

  def index
    if current_user.boards.blank?
      redirect_to repos_url
      return
    end
  end

  def show
    @board_issues = github_api.board_issues(@board)
    # FIX : Add cache for labels
    @labels = github_api.labels(@board)
    # FIX : Move to helper_method and remove @issue
    @issue = Issue.new(labels: @labels.map(&:name))
  end

  def new
    repo = github_api.cached_repos.select { |r| r.id == params[:github_id].to_i }.first
    @board = Board.new(name: repo.name, github_id: repo.id, github_name: repo.name)
  end

  def create
    @board = current_user.boards.new(board_params)
    @board.columns << build_columns

    if @board.save
      redirect_to board_url(@board)
    else
      render 'new'
    end
  end

  def destroy
    if current_user.owner?(@board)
      @board.destroy
      redirect_to repos_url, notice: "Your board \"#{@board.name}\" was successfully deleted."
    else
      raise ActiveRecord::RecordNotFound
    end
  end

private

  def board_params
    params
      .require(:board)
      .permit(:name, :type, :github_id, :github_name)
  end

  def column_params
    params
      .require(:board)
      .require(:column)
      .permit(name: [])
  end

  def build_columns
    order = 0
    column_params[:name].select { |name| name.present? }.inject([]) do |mem, name|
      order = order + 1
      column = Column.new(name: name, color: 'fbca04', order: order, board: @board)
      mem << column
    end
  end

  def fetch_repo_history
    # FIX : This tasks also add to wenever
    Graphs::LinesWorker.perform_async(@board.id, github_token)
    Graphs::CumulativeWorker.perform_async(@board.id, github_token)
    Graphs::IssueStatsWorker.perform_async(@board.id, github_token)
  end

  def check_permissions
    unless current_user_admin?(board_params[:github_id])
      # NOTE : Not enough permissions to create board.
      raise ActiveRecord::ReadOnlyRecord
    end
  end
end
