module Cached
  class ReadIssues < Cached::Issues
    attribute :board, Board

    def call
      Cached::ReadBase.call(key: key)
    end
  end
end
