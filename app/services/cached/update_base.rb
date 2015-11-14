module Cached
  class UpdateBase
    include Service
    include Virtus.model

    READONLY_EXPIRES_IN = 1.month

    attribute :objects, Object
    attribute :key, String

    def call
      Rails.cache.write(
        key,
        Cached::Item.new(objects, Time.current),
        expires_in: READONLY_EXPIRES_IN
      )
      objects
    end
  end
end
