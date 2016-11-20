module IssueStats
  class DueDater
    include IdentityHelper
    include Service
    include Virtus.model

    attribute :user, User
    attribute :board_bag, BoardBag
    attribute :number, Integer
    attribute :due_date_at, DateTime

    def call
      issue_stat.update(due_date_at: due_date_at)
      Activities::ChangeDueDate.create_for(issue_stat, user)
      issue_stat
    end
  end
end

