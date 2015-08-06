class SubscriptionsController < ApplicationController
  before_action :fetch_board_for_update

  def new
  end

  def early_access
    subscription = Subscriber.early_access(@board, current_user)
    redirect_to un(board_url(@board)),
      notice: "Subscribed until #{subscription.date_to.strftime('%d-%m-%Y')}"
  end
end
