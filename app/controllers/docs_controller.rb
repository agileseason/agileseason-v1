class DocsController < ApplicationController
  skip_authorization_check unless: -> { current_user }

  def main
    redirect_to board_features_docs_url
  end
end
