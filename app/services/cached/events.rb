module Cached
  class Events < Cached::Base
    attribute :user, User
    attribute :board, Board
    attribute :number, Integer

    private

    def fetch
      user.github_api.issue_events(board, number)
    end

    def expires_in
      20.second
    end

    def key_identity
      "events_#{number}"
    end
  end
end
