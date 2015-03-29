class BoardBag
  pattr_initialize :github_api, :board
  delegate :github_name, :github_full_name, :columns, :to_param, to: :board

  def issues
    @issues ||= cached(:board_issues, 5.minutes) { @github_api.board_issues(@board) }
  end

  def collaborators
    @collaborators ||= cached(:collaborators, 20.minutes) { @github_api.collaborators(@board) }
  end

  def labels
    @labels ||= cached(:labels, 20.minutes) { @github_api.labels(@board) }
  end

  def build_issue_new
    Issue.new(labels: labels.map(&:name))
  end

  def issues_of_column column

    if column.issues
      ordered_issues = []
      column.issues.each do |i|
        issues[column.id].reject(&:archive?).each do |issue|
          if i.to_i == issue.number
            ordered_issues << issue
          end
        end
      end
      ordered_issues

    else
      issues[column.id].reject(&:archive?)
    end
  end

  private

  def cache_key(posfix)
    [@board, "board_bag_#{posfix}"]
  end

  def cached(posfix, expires_in, &block)
    if Rails.env.test?
      block.call
    else
      Rails.cache.fetch(cache_key(posfix), expires_in: expires_in) do
        block.call
      end
    end
  end
end
