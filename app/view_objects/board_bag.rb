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

  def column_issues column
    if column.issues
      ordered_issues(column).concat unordered_issues(column)
    else
      issues[column.id].reject(&:archive?)
    end
  end

  private

  def ordered_issues column
    column.issues.each_with_object([]) do |number, array|
      array << issues[column.id].find do |issue|
        number.to_i == issue.number && !issue.archive?
      end
    end
  end

  def unordered_issues column
    issues[column.id].select { |issue| !column.issues.include?(issue.number.to_s) }
  end

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
