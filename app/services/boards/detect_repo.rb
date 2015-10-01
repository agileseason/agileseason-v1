module Boards
  class DetectRepo
    include Service
    include Virtus.model

    attribute :user, User
    attribute :board, Board

    def call
      repos.detect { |repo| repo.id == board.github_id }
    end

    private

    def repos
      @repos ||= user.github_api.cached_repos
    end
  end
end
