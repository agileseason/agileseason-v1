class MarkdownController < ApplicationController
  before_action :fetch_board

  def preview
    render html: markdown(params[:string], @board.github_url)
  end
end
