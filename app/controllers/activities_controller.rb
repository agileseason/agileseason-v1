class ActivitiesController < ApplicationController
  before_action :fetch_board

  def index
    @activities = @board.activities.paginate(page: params[:page])
    render partial: 'index' if @activities
  end
end
