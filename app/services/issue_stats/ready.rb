module IssueStats
  class Ready
    include Service
    include Virtus.model

    attribute :user, User
    attribute :board_bag, BoardBag
    attribute :number, Integer

    def call
      issue_stat = IssueStats::Finder.new(user, board_bag, number).call
      issue_stat.update(is_ready: true)
      issue_stat
    end
  end
end
