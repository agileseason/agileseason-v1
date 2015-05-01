class DocsController < ApplicationController
  skip_before_filter :authenticate, unless: -> { current_user }

  def cumulative
  end

  def control
  end
end
