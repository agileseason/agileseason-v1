class BoardIssue
  include MarkdownHelper

  attr_accessor :issue, :issue_stat
  delegate :number, :title, :body, :state, :labels, :html_url,
           :assignee, :comments, :all_comments,
           :created_at, :updated_at, :closed_at, to: :issue
  delegate :board, :column_id, :ready?,
           :checklist, :checklist_progress, to: :issue_stat

  attr_initialize :issue, :issue_stat

  def archive?
    issue_stat.present? && issue_stat.archived?
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

  def no_comments_available?
    issue.comments > 0 && comments == 0
  end

  def due_date_at
    issue_stat.due_date_at unless issue_stat.nil?
  end

  def column
    issue_stat.column unless issue_stat.nil?
  end

  def column_id
    return nil if issue_stat.nil?
    issue_stat.column_id
  end

  def to_hash
    {
      number: number,
      title: title,
      body: body,
      bodyMarkdown: markdown(body, board),
      dueDate: issue_stat.due_date_at ? issue_stat.due_date_at.to_datetime.utc.to_i * 1000 : nil,
      columns: board.columns.map { |c| { id: c.id, name: c.name } },
      columnId: column_id,
    }
  end
end
