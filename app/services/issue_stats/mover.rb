module IssueStats
  class Mover
    pattr_initialize :user, :board_bag, :column_to, :number

    def call
      if column_will_change?
        # TODO Extract IssueStats::ColumnChangeActivity
        if user.present? && issue_stat.column != column_to
          Activities::ColumnChangedActivity.
            create_for(issue_stat, issue_stat.column, column_to, user)
        end
        issue_stat.update!(column: column_to)
        IssueStats::LifetimeFinisher.new(issue_stat).call
        IssueStats::LifetimeStarter.new(issue_stat, column_to).call
      end

      issue_stat
    end

    # NOTE Public until end refactoring

    def issue_stat
      @issue_stat ||= IssueStats::Finder.new(user, board_bag, number).call
    end

    private

    def board
      board_bag.board
    end

    def column_will_change?
      column_to != issue_stat.column
    end
  end
end
