module IssueStats
  class Mover
    include Service
    include Virtus.model
    include IdentityHelper

    attribute :user, User
    attribute :board_bag, BoardBag
    attribute :column_to, Column
    attribute :number, Integer
    attribute :is_force_sort, Boolean

    def call
      if column_will_change?
        Activities::ColumnChangedActivity.create_for(issue_stat, column_from, column_to, user)
        Lifetimes::Finisher.new(issue_stat).call
        Lifetimes::Starter.new(issue_stat, column_to).call
        IssueStats::Unready.call(user: user, board_bag: board_bag, number: number)
        issue_stat.update!(column: column_to)
      end
      IssueStats::AutoAssigner.call(user: user, board_bag: board_bag, column: column_to, number: number)
      IssueStats::AutoCloser.call(user: user, board_bag: board_bag, column: column_to, number: number)
      IssueStats::Sorter.call(column_to: column_to, number: number, is_force_sort: is_force_sort)

      issue_stat
    end

    private

    def column_from
      @column_from ||= issue_stat.column
    end

    def column_will_change?
      column_to != column_from
    end
  end
end
