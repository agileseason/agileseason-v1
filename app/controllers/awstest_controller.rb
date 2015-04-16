class AwstestController < ApplicationController
  def index
    @direct_post = S3Api.direct_post
  end
end
