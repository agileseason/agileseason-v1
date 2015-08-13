module Activities
  class ColumnChangedActivity < Activity
    def self.create_for(issue_stat, column_from, column_to, user)
      Activities::ColumnChangedActivity.create!(
        board: issue_stat.board,
        user: user,
        issue_stat: issue_stat,
        data: { column_from: column_from.try(:name), column_to: column_to.try(:name) }
      )
    end

    def description(issue_url)
      "moved #{link_to(issue_url)} from #{column_name(:column_from)} to the #{column_name(:column_to)}"
    end

    private

    def column_name(key)
      if data && data[key]
        data[key]
      else
        '???'
      end
    end
  end
end
