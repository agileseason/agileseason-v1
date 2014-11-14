class BoardsController < ApplicationController
  def index
    if current_user.boards.blank?
      redirect_to repos_url
      return
    end
  end

  def new
    repo = GithubApi.new(github_token).repos.select{ |r| r.id == params[:github_id].to_i }.first
    @board = Board.new(name: repo.name, github_id: repo.id)
  end

  def create
    @board = current_user.boards.new(board_params)
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
end
