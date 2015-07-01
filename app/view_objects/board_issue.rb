class BoardIssue
  attr_accessor :issue, :issue_stat
  delegate :number, :title, :body, :state, :labels, :html_url,
           :assignee, :comments, :all_comments, to: :issue
  delegate :board, :due_date_at, :column_id, to: :issue_stat

  attr_initialize :issue, :issue_stat

  def archive?
    issue_stat.archived?
  end
  alias :archived? :archive?

  def open?
    state == 'open'
  end

  def closed?
    state == 'closed'
  end

  def visible?
    issue_stat.present? && !archived?
  end
end
