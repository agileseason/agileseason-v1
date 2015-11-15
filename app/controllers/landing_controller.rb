class LandingController < ApplicationController
  skip_before_filter :authenticate, unless: -> { signed_in? }
  layout 'landing'

  def index
    return redirect_to boards_url if signed_in?
  end

  def demo
    session[:return_url] = "#{Agileseason::DOMAIN}/boards/agileseason/agileseason"
    redirect_to '/auth/github'
  end
end
