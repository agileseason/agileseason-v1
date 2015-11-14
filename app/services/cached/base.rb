module Cached
  class Base
    include Service
    include Virtus.model

    attribute :user, User
    attribute :board, Board

    def call
      return if user.guest? && !board.public?
      return current.try(:value) if user.guest?
      return current.value unless expired?(current)

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

    def key
      "board_bag_#{key_identity}_#{board.id}"
    end

    def expired?(obj)
      obj.nil? || obj.fetched_at < Time.current - expires_in
    end

    def current
      @current ||= Cached::ReadBase.call(key: key)
    end
  end
end
