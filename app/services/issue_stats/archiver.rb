module IssueStats
  class Archiver
    include IdentityHelper
    include Service
    include Virtus.model

    attribute :user, User
    attribute :board_bag, BoardBag
    attribute :number, Integer

    def call
      return unless github_issue.state == 'closed'

      Activities::ArchiveActivity.create_for(issue_stat, user)
      issue_stat.update!(archived_at: Time.current)
      issue_stat
    end
  end
end
