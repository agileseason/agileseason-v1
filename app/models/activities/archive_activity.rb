module Activities
  class ArchiveActivity < Activity
    def self.create_for(board, number, user)
      Activities::ArchiveActivity.create!(
        board: board,
        user: user,
        data: { number: number }
      )
    end

    def issue_number
      data && data[:number]
    end

    def issue_stat
      @issue_stat ||= board.issue_stats.find_by(number: issue_number)
    end
  end
end
