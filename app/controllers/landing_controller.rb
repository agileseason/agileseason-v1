class LandingController < ApplicationController
  skip_before_filter :authenticate, unless: -> { current_user }

  def index
  end
end
