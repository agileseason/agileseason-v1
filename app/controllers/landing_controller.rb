class LandingController < ApplicationController
  AUTH_URL = '/auth/github'
  DEMO_URL = "#{Agileseason::DOMAIN}/boards/agileseason/agileseason"

  skip_before_filter :authenticate, unless: -> { signed_in? }
  layout 'landing'

  def index
    return redirect_to boards_url if signed_in?
  end

  def demo
    session[:return_url] = DEMO_URL
    redirect_to AUTH_URL
  end
end
