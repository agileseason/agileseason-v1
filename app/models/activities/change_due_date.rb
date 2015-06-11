module Activities
  class ChangeDueDate < Activity
    def self.create_for(issue_stat, user)
      Activities::ChangeDueDate.create!(
        issue_stat: issue_stat,
        board: issue_stat.board,
        user: user,
        data: { due_date_at: issue_stat.due_date_at }
      )
    end

    def description
      "changed due date to - #{due_date}"
    end

    private

    def due_date
      if data && data[:due_date_at]
        data[:due_date_at].strftime('%b %d %H:%M')
      else
        'nil'
      end
    end
  end
end
