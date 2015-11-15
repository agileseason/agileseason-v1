module Cached
  class UpdateIssues < Cached::Issues
    attribute :board, Board
    attribute :objects, Object

    def call
      Cached::UpdateBase.call(objects: objects, key: key)
    end
  end
end
