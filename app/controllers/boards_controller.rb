class BoardsController < ApplicationController
  after_action :fetch_repo_history, only: :show

  def index
    if current_user.boards.blank?
      redirect_to repos_url
      return
    end
  end

  def show
    @board = current_user.boards.find(params[:id])
    @issues = github_api.board_issues(@board)
  end

  def new
    repo = github_api.cached_repos.select { |r| r.id == params[:github_id].to_i }.first
    @board = Board.new(name: repo.name, github_id: repo.id)
  end

  def create
    @board = current_user.boards.new(board_params)
    @board.columns << build_columns
    github_api.sync_labels(@board)

    if @board.save
      redirect_to boards_url
    else
      render 'new'
    end
  end

private

  def board_params
    params
      .require(:board)
      .permit(:name, :github_id, :type)
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
      column = Column.new(name: name, color: 'fbca04', order: order)
      mem << column
    end
  end

  def fetch_repo_history
    Graphs::LinesWorker.perform_async(@board.id, github_token)
  end
end
