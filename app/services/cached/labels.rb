module Cached
  class Labels
    include Service
    include Virtus.model

    EXPIRES_IN = 15.minutes
    READONLY_EXPIRES_IN = 1.month

    attribute :user, User
    attribute :board, Board

    def call
      return if user.guest? && !board.public?
      return current.try(:value) if user.guest?
      return current.value unless expired?(current)

      labels = user.github_api.labels(board)
      Rails.cache.write(
        key,
        Cached::Base.new(labels, Time.current),
        expires_in: READONLY_EXPIRES_IN
      )
      labels
    end

    private

    def expired?(obj)
      obj.nil? || obj.fetched_at < Time.current - EXPIRES_IN
    end

    def current
      @current ||= Rails.cache.read(key)
    end

    def key
      cache_key(:labels)
    end

    # TODO Specification for inheritors
    def cache_key(postfix)
      if postfix == :issues_hash
        "board_bag_#{postfix}_#{board.id}_#{board.updated_at.to_i}"
      else
        "board_bag_#{postfix}_#{board.id}"
      end
    end
  end
end
