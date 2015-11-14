module Cached
  class Base
    include Service
    include Virtus.model

    READONLY_EXPIRES_IN = 1.month

    attribute :user, User
    attribute :board, Board

    def call
      return if user.guest? && !board.public?
      return current.try(:value) if user.guest?
      return current.value unless expired?(current)

      objects = fetch

      Rails.cache.write(
        key,
        Cached::Item.new(objects, Time.current),
        expires_in: READONLY_EXPIRES_IN
      )
      objects
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

    def key
      cache_key(key_identity)
    end

    def expired?(obj)
      obj.nil? || obj.fetched_at < Time.current - expires_in
    end

    def current
      @current ||= Rails.cache.read(key)
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
