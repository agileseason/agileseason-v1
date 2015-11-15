module Cached
  class Labels < Cached::Base
    attribute :user, User
    attribute :board, Board

    private

    def fetch
      user.github_api.labels(board)
    end

    def expires_in
      15.minutes
    end

    def key_identity
      :labels
    end
  end
end
