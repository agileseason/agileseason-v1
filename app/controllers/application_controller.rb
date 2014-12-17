class ApplicationController < ActionController::Base
  include ApplicationHelper

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :authenticate
  helper_method :current_user, :signed_in?

  private

  def authenticate
    redirect_to root_url unless signed_in?
  end

  def signed_in?
    current_user.present?
  end

  def current_user
    @current_user ||= User.where(remember_token: session[:remember_token]).first
  end

  def fetch_board
    @board = current_user.boards.find(params[:board_id])
  end
end
