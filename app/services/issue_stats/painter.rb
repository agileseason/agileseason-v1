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
      issue_stat.update(color: normolized_color)
      issue_stat
    end

  private

    def normolized_color
      return nil if color.downcase == '#ffffff'
      return color
    end
  end
end

