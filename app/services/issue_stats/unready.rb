module IssueStats
  class Unready
    pattr_initialize :user, :board_bag, :number

    def call
      issue_stat = IssueStats::Finder.new(user, board_bag, number).call
      issue_stat.update(is_ready: false)
      issue_stat
    end
  end
end
