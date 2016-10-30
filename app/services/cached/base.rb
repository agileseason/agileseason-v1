module Cached
  class Base
    include Service
    include Virtus.model

    NO_DATA = [].freeze

    attribute :user, User
    attribute :board, Board

    def call
      return if readonly? && board.private?
      return readonly_value if readonly?
      return current.value unless expired?

      Cached::UpdateBase.call(objects: fetch, key: key)
    end

  private

    def fetch
      # See inheritors
    end

    def expires_in
      # See inheritors
    end

    def key_identity
      # See inheritors
    end

    def no_data
      # Can be changed in inheritors
      NO_DATA
    end

    def key
      "board_bag_#{key_identity}_#{board.id}"
    end

    def expired?
      current.nil? || current.fetched_at < Time.current - expires_in
    end

    def current
      @current ||= Cached::ReadBase.call(key: key)
    end

    def readonly?
      user.guest? || github_repo.nil?
    end

    def readonly_value
      return no_data if current.nil?
      current.value
    end

    def github_repo
      @github_repo ||= Boards::DetectRepo.call(user: user, board: board)
    end
  end
end
