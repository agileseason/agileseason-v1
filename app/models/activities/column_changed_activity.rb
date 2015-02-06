module Activities
  class ColumnChangedActivity < Activity
    def self.create_for(issue_stat, column_from, column_to, user)
      Activities::ColumnChangedActivity.create!(
        board: issue_stat.board,
        user: user,
        issue_stat: issue_stat,
        data: { column_from: column_from, column_to: column_to }
      )
    end

    def description
      # FIX : Add column from after save it.
      "Move to '#{column_to}' Issue"
    end

    private

    def column_to
      if data && data[:column_to]
        data[:column_to]
      else
        '???'
      end
    end
  end
end
