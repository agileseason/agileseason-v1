module Cached
  class ReadBase
    include Service
    include Virtus.model

    attribute :key, String

    def call
      Rails.cache.read(key)
    end
  end
end
