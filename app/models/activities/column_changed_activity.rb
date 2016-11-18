module Activities
  class ColumnChangedActivity < Activity
    def self.create_for(issue_stat, column_from, column_to, user)
      return if user.nil?

      Activities::ColumnChangedActivity.create!(
        board: issue_stat.board,
        user: user,
        issue_stat: issue_stat,
        data: { column_from: column_from.try(:name), column_to: column_to.try(:name) }
      )
    end

    def description(issue_url)
      "moved #{link_to_issue(issue_url)} \
        from <span class='column'>#{column_name(:column_from)}</span> \
        to the <span class='column'>#{column_name(:column_to)}</span>"
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
