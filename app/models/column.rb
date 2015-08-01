class Column < ActiveRecord::Base
  belongs_to :board
  has_many :issue_stats, dependent: :destroy
  has_many :visible_issue_stats, -> { visible }, class_name: IssueStat
  has_many :lifetimes, dependent: :destroy

  validates :name, presence: true
  validates :board, presence: true
  validates :wip_min, :wip_max, numericality: true, allow_nil: true

  serialize :issues

  def next_columns
    board.columns.select { |c| c.order > order }
  end

  def prev_columns
    board.columns.select { |c| c.order < order }
  end

  def issues
    self['issues'] = [] if self['issues'].nil?
    self['issues']
  end

  def update_sort_issues(issues)
    issues = [] if issues.nil?
    issue_ids = issues.map(&:to_s).reject { |n| n == 'empty' }.uniq
    update(issues: issue_ids)
  end

  def auto_assign?
    is_auto_assign.present?
  end
end
