class MarkdownController < ApplicationController
  def preview
    render html: markdown(params[:string])
  end
end
