class ExportsController < ApplicationController
  layout false

  before_action :fetch_board

  def show
    render 'exports/board.text', content_type: 'text/plain'
  end
end
