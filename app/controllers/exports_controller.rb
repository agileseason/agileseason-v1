class ExportsController < ApplicationController
  before_action :fetch_board
  helper_method :current_type

  def show
  end

  private

  def current_type
    case params[:type]
    when 'markdown'
      :markdown
    when 'html'
      :html
    when 'text'
      :text
    else
      :markdown
    end
  end
end
