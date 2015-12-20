class BoardsController < ApplicationController
  load_and_authorize_resource
  skip_authorize_resource only: [:new, :create]

  before_action :check_permissions,  only: [:create]
  before_action :fetch_board,        only: [:show, :destroy]
  before_action :check_subscription, only: [:show]

  after_action :first_init_issues, only: [:create]

  def index
    @boards_lists = [
      { title: 'My Boards', boards: BoardPick.list_by(current_user, k(:user, current_user).boards) },
      { title: 'Explore Public Boards', boards: BoardPick.public_list },
    ]

    render partial: 'board_list' if request.xhr?
  end

  def show
  end

  def new
    repo = github_api.cached_repos.detect { |r| r.id == params[:github_id].to_i }
    @board = Board.new(
      name: repo.name,
      github_id: repo.id,
      github_name: repo.name,
      github_full_name: repo.full_name,
      is_private_repo: repo.private
    )
    ui_event(:board_new, step: 'setup board')

    render partial: 'new', locals: { board: @board }
  end

  def create
    @board = current_user.boards.new(board_params)
    @board.columns << build_columns

    if @board.save
      WebhookWorker.perform_async(@board.id, encrypted_github_token)
      ui_event(:board_create)
      redirect_to un board_url(@board)
    else
      render 'new'
    end
  end

  def destroy
    authorize! :destroy, @board
    github_api.remove_issue_hook(@board)
    @board.destroy
    redirect_to un(boards_url), notice: "Your board \"#{@board.name}\" was successfully deleted."
  end

  private

  def board_params
    params.
      require(:board).
      permit(
        :name, :type, :github_id, :github_name,
        :github_full_name, :is_private_repo
      )
  end

  def column_params
    params.
      require(:board).
      require(:column).
      permit(name: [])
  end

  def build_columns
    order = 0
    column_params[:name].select(&:present?).map do |name|
      order += 1
      Column.new(name: name, order: order, board: @board)
    end
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

  def first_init_issues
    BoardBag.new(current_user, @board).board_issues
  end
end
