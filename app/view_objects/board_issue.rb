class BoardIssue
  include MarkdownHelper

  attr_accessor :issue, :issue_stat
  delegate :number, :title, :body, :state, :labels, :html_url,
           :assignee, :comments, :all_comments,
           :created_at, :updated_at, :closed_at, to: :issue
  delegate :board, :column_id, :ready?, :color,
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

  def due_date_success?
    return false unless due_date_at
    return false unless closed?
    issue.closed_at < due_date_at
  end

  def due_date_passed?
    return false unless due_date_at
    return false if closed? && due_date_at > closed_at

    due_date_at < Time.current
  end

  def column
    issue_stat.column unless issue_stat.nil?
  end

  def column_id
    return nil if issue_stat.nil?
    issue_stat.column_id
  end

  def to_hash
    to_hash_min.merge(
      body: body,
      bodyMarkdown: markdown(body, board)
    )
  end

  def to_hash_min
    {
      number: number,
      title: title,
      assignee: assignee_to_hash,
      dueDate: due_date_at_to_js,
      columns: board.columns.map { |c| { id: c.id, name: c.name } },
      columnId: column_id,
      state: full_state,
      closed_at: closed_at,
      isReady: ready?,
      color: color || IssueStats::Painter::DEFAULT_COLOR,
      commentCount: comments
    }
  end

  private

  def assignee_to_hash
    return unless assignee
    { login: assignee.login, avatarUrl: assignee.avatar_url }
  end

  def due_date_at_to_js
    return if due_date_at.nil?
    due_date_at.to_datetime.utc.to_i * 1000
  end
end
