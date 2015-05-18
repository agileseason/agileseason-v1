class BoardsController < ApplicationController
  load_and_authorize_resource
  skip_authorize_resource only: [:new, :create]

  before_action :check_permissions,  only: [:create]
  before_action :fetch_board,        only: [:show, :destroy]
  after_action  :fetch_repo_history, only: [:show], unless: -> { Rails.env.test? }

  def index
    if current_user.boards.blank?
      redirect_to repos_url
      return
    end
    @boards_lists = [
      { title: 'My Boards', boards: BoardPick.list_by(k(:user, current_user).boards) },
      { title: 'Explore Public Boards', boards: BoardPick.public_list },
    ]
  end

  def show
    @direct_post = S3Api.direct_post
  end

  def new
    repo = github_api.cached_repos.select { |r| r.id == params[:github_id].to_i }.first
    @board = Board.new(
      name: repo.name,
      github_id: repo.id,
      github_name: repo.name,
      github_full_name: repo.full_name
    )
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
    authorize! :destroy, @board
    @board.destroy
    redirect_to repos_url, notice: "Your board \"#{@board.name}\" was successfully deleted."
  end

private

  def board_params
    params.
      require(:board).
      permit(:name, :type, :github_id, :github_name, :github_full_name)
  end

  def column_params
    params.
      require(:board).
      require(:column).
      permit(name: [])
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
    Graphs::LinesWorker.perform_async(@board.id, github_token)
    Graphs::CumulativeWorker.perform_async(@board.id, github_token)
    Graphs::IssueStatsWorker.perform_async(@board.id, github_token)

    BoardWorker.perform_async(@board.id, github_token)
  end

  def check_permissions
    unless current_user.repo_admin?(board_params[:github_id])
      # NOTE : Not enough permissions to create board.
      raise ActiveRecord::ReadOnlyRecord
    end
  end

  def issue_new
    Issue.new(labels: @board_bag.labels.map(&:name))
  end
end
