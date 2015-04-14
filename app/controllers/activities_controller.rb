class ActivitiesController < ApplicationController
  before_action :fetch_board

  def index
    @activities = @board.activities.paginate(page: params[:page])
    paginate_activities
  end

  private

  def paginate_activities
    if @activities.next_page
      render partial: 'index'
    else
      render nothing: true
    end
  end
end
