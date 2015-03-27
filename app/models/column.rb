class Column < ActiveRecord::Base
  belongs_to :board
  has_many :issue_stats, dependent: :delete_all

  validates :name, presence: true
  validates :board, presence: true

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
