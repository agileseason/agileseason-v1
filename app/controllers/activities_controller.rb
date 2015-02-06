class ActivitiesController < ApplicationController
  before_action :fetch_board

  def index
    render partial: 'index'
  end
end
