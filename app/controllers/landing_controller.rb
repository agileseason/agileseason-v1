class LandingController < ApplicationController
  skip_before_filter :authenticate, unless: -> { current_user }

  def index
    return redirect_to boards_url if current_user
    ui_event(:landing)
  end
end
