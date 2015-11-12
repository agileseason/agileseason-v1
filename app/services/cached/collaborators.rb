module Cached
  class Collaborators < Cached::ItemsBase
    attribute :user, User
    attribute :board, Board

    private

    def fetch
      user.github_api.collaborators(board)
    end

    def expires_in
      20.minutes
    end

    def key_identity
      :collaborators
    end
  end
end
