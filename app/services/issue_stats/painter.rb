module IssueStats
  class Painter
    include Service
    include Virtus.model

    attribute :user, User
    attribute :board_bag, BoardBag
    attribute :number, Integer
    attribute :color, String

    def call
      issue_stat = IssueStats::Finder.new(user, board_bag, number).call
      issue_stat.update(color: color)
      issue_stat
    end
  end
end

