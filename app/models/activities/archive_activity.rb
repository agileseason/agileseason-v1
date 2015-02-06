module Activities
  class ArchiveActivity < Activity
    def self.create_for(issue_stat, user)
      Activities::ArchiveActivity.create!(
        board: issue_stat.board,
        user: user,
        issue_stat: issue_stat
      )
    end

    def description
      'Archived Issue'
    end
  end
end
