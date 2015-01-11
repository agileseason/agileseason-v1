class BoardsController < ApplicationController
  after_action :fetch_repo_history, only: :show
  before_action :fetch_board, only: :show
  before_action :check_permissions, only: :create

  def index
    if current_user.boards.blank?
      redirect_to repos_url
      return
    end
  end

  def show
    @issues = github_api.board_issues(@board)
    labels = github_api.labels(@board).map(&:name)
    @issue = Issue.new(labels: labels)

    colors = github_api.labels(@board).map(&:color)
    @labels = labels_with_colors(labels, colors)
  end

  def new
    repo = github_api.cached_repos.select { |r| r.id == params[:github_id].to_i }.first
    @board = Board.new(name: repo.name, github_id: repo.id, github_name: repo.name)
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
      column = Column.new(name: name, color: 'fbca04', order: order)
      mem << column
    end
  end

  def fetch_repo_history
    # FIX : This tasks also add to wenever
    Graphs::LinesWorker.perform_async(@board.id, github_token)
    Graphs::CumulativeWorker.perform_async(@board.id, github_token)
  end

  def check_permissions
    unless current_user_admin?(board_params[:github_id])
      # NOTE : Not enough permissions to create board.
      raise ActiveRecord::ReadOnlyRecord
    end
  end

  def labels_with_colors(labels, colors)
    labels_array = []
    labels.each_with_index do |label, label_index|
      colors.each_with_index do |color, color_index|
        if label_index == color_index
          labels_array << { name: label, color: color }
        end
      end
    end
    labels_array
  end
end
