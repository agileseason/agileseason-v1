class IssuesController < ApplicationController
  before_action :fetch_board

  def new
    labels = github_api.labels(@board).map(&:name)
    @issue = Issue.new(labels: labels)
  end

  def create
    @issue = Issue.new(issue_params)
    if @issue.valid?
      github_api.create_issue(@board, @issue)
      redirect_to board_url(@board)
    else
      render 'new'
    end
  end

  def show
    @issue = github_api.issue(@board, params[:number])
    @comments = github_api.issue_comments(@board.github_id, params[:number].to_i)
    @labels = github_api.labels(@board)
    render partial: 'show'
  end

  def move_to
    github_api.move_to(@board, @board.columns.find(params[:column_id]), params[:number])
    redirect_to board_url(@board)
  end

  def close
    github_api.close(@board, params[:number])
    redirect_to board_url(@board)
  end

  def archive
    issue_stat = github_api.archive(@board, params[:number])
    respond_to do |format|
      format.html { redirect_to board_url(@board) }
      format.json { render json: { archived: issue_stat && issue_stat.archived? } }
    end
  end

  def assignee
    github_api.assign_yourself(@board, params[:number], current_user.github_username)
    redirect_to board_url(@board)
  end

  def update
    github_api.update_issue(@board, params[:number],
      body: params[:body],
      title: params[:title],
      labels: params[:labels])
    redirect_to board_url(@board)
  end

  private

  def issue_params
    params
      .require(:issue)
      .permit(:title, :body, labels: [])
  end
end
