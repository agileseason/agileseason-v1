module IssueStats
  class Unarchiver
    include IdentityHelper

    pattr_initialize :user, :board_bag, :number

    def call
      return unless issue_stat.archive?

      Activities::UnarchiveActivity.create_for(issue_stat, user)
      IssueStats::LifetimeStarter.new(issue_stat, issue_stat.column).call
      issue_stat.update!(archived_at: nil)
      issue_stat
    end
  end
end
