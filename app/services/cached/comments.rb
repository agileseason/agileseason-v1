module Cached
  class Comments < Cached::Base
    attribute :user, User
    attribute :board, Board
    attribute :number, Integer

    def call
      return super if board.public? && board.private_repo?
      fetch
    end

    private

    def fetch
      user.github_api.issue_comments(board, number)
    end

    def expires_in
      1.second
    end

    def key_identity
      "comments_#{number}"
    end
  end
end
