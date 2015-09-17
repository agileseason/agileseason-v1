class DocsController < ApplicationController
  skip_before_filter :authenticate, unless: -> { current_user }

  def main
    redirect_to board_features_docs_url
  end
end
