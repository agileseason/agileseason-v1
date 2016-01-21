class ExportsController < ApplicationController
  before_action :fetch_board
  helper_method :current_type

  def show
    #render 'exports/board.text', content_type: 'text/plain'
  end

  private

  def current_type
    case params[:type]
      when 'html'
        :html
      when 'text'
        :text
      when 'markdown'
        :markdown
      else
        :markdown
    end
  end
end
