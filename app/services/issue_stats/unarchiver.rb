module IssueStats
  class Unarchiver
    include IdentityHelper
    include Service
    include Virtus.model

    attribute :user, User
    attribute :board_bag, BoardBag
    attribute :number, Integer

    def call
      return unless issue_stat.archive?

      Activities::UnarchiveActivity.create_for(issue_stat, user)
      issue_stat.update!(archived_at: nil)
      issue_stat
    end
  end
end
