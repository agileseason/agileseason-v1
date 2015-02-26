class ColumnTransporter
  def initialize(column)
    @column = column
  end

  def can_move?
    !@column.issue_stats.where(archived_at: nil).any?
  end

  def move_left
    all_columns.each { |column| column.order *= 10 }
    column_to_move = all_columns.detect { |column| column.id == @column.id }
    column_to_move.order -= 11
    normolize_order
  end

  def move_right
    all_columns.each { |column| column.order *= 10 }
    column_to_move = all_columns.detect { |column| column.id == @column.id }
    column_to_move.order += 11
    normolize_order
  end

  private

  def all_columns
    @all_columns ||= @column.board.columns
  end

  def normolize_order
    all_columns.sort_by(&:order).each_with_index { |column, index| column.order = index + 1 }
    all_columns.map(&:save)
  end
end
