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
    # TODO : Save Board
  end
end
