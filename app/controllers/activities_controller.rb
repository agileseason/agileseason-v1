class ActivitiesController < ApplicationController
  before_action :fetch_board

  def index
    @activities = @board.activities.paginate(page: params[:page], per_page: 20)

    if params[:page]
      paginate_activities

    else
      render partial: 'index'
    end
  end

private
  def paginate_activities
    if @activities.count/20 >= params[:page].to_i
      render partial: 'index'
    else
      render nothing: true
    end
  end
end
