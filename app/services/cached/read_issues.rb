module Cached
  class ReadIssues < Cached::Issues
    attribute :board, Board

    def call
      Cached::ReadBase.call(key: key).try(:value)
    end
  end
end
