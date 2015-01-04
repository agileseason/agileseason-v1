class Column < ActiveRecord::Base
  belongs_to :board

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
