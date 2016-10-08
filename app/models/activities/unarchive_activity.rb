module Activities
  class UnarchiveActivity < Activity
    def self.create_for(issue_stat, user)
      Activities::UnarchiveActivity.create!(
        board: issue_stat.board,
        user: user,
        issue_stat: issue_stat
      )
    end

    def description(issue_url)
      "#{link_to_issue(issue_url)} sent to the board"
    end
  end
end
