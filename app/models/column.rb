class Column < ActiveRecord::Base
  belongs_to :board
  has_many :issue_stats, dependent: :destroy

  validates :name, presence: true
  validates :board, presence: true

  serialize :issues

  def label_name
    "[#{order}] #{name}"
  end

  def next_columns
    board.columns.select { |c| c.order > order }
  end

  def prev_columns
    board.columns.select { |c| c.order < order }
  end
end
