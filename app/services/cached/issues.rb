module Cached
  class Issues < Cached::Base
    NO_DATA = {}.freeze

    attribute :user, User
    attribute :board, Board

    private

    def fetch
      user.github_api.issues(board).each_with_object({}) do |issue, hash|
        hash[issue.number] = issue
      end
    end

    def expires_in
      5.minutes
    end

    def key_identity
      :issues_hash
    end

    def no_data
      NO_DATA
    end
  end
end
