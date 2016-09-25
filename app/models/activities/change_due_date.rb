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

    def description(issue_url)
      return "removed due date for #{link_to(issue_url)}" if due_date.nil?
      "changed due date for #{link_to(issue_url)} on #{due_date}"
    end

    private

    def due_date
      return if data.blank?
      return if data[:due_date_at].nil?

      data[:due_date_at].strftime('%b %d %H:%M')
    end
  end
end
