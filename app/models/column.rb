class Column < ActiveRecord::Base
  belongs_to :board
  has_many :issue_stats, dependent: :destroy
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
end
