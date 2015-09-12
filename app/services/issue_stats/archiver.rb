module IssueStats
  class Archiver
    include IdentityHelper

    pattr_initialize :user, :board_bag, :number

    def call
      return unless github_issue.state == 'closed'

      Activities::ArchiveActivity.create_for(issue_stat, user)
      IssueStats::LifetimeFinisher.new(issue_stat).call
      issue_stat.update!(archived_at: Time.current)
      issue_stat
    end
  end
end
