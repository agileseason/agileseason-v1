class BoardIssue
  attr_accessor :issue, :issue_stat
  delegate :number, :title, :body, :state, :labels, :html_url,
           :assignee, :comments, :all_comments,
           :created_at, :updated_at, :closed_at, to: :issue
  delegate :board, :due_date_at, :column, :column_id, :ready?,
           :checklist, :checklist_progress, to: :issue_stat

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

  def full_state
    return 'archived' if archive?
    state
  end
end
