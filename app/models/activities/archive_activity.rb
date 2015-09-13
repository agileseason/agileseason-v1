module Activities
  class ArchiveActivity < Activity
    def self.create_for(issue_stat, user)
      return if user.nil?

      Activities::ArchiveActivity.create!(
        board: issue_stat.board,
        user: user,
        issue_stat: issue_stat
      )
    end

    def description(issue_url)
      "archived #{link_to(issue_url)}"
    end
  end
end
