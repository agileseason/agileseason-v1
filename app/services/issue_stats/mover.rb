module IssueStats
  class Mover
    pattr_initialize :user, :board_bag, :column_to, :number

    def call
      if column_will_change?
        Activities::ColumnChangedActivity.create_for(issue_stat, column_from, column_to, user)
        IssueStats::LifetimeFinisher.new(issue_stat).call
        IssueStats::LifetimeStarter.new(issue_stat, column_to).call
        issue_stat.update!(column: column_to)
      end

      issue_stat
    end

    private

    def issue_stat
      @issue_stat ||= IssueStats::Finder.new(user, board_bag, number).call
    end

    def column_from
      @column_from ||= issue_stat.column
    end

    def board
      board_bag.board
    end

    def column_will_change?
      column_to != column_from
    end
  end
end
