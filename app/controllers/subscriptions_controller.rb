class SubscriptionsController < ApplicationController
  before_action :fetch_board_for_update

  def new
  end

  def early_access
    Subscriber.early_access(@board, current_user)
    redirect_to board_url(@board)
  end
end
