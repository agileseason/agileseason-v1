class LandingController < ApplicationController
  skip_before_filter :authenticate, unless: -> { current_user }

  def index
    ui_event(:landing)
    return redirect_to boards_url if current_user
  end
end
