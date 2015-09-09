# NOTE Rename to ColumnMover.
class ColumnTransporter
  def initialize(column)
    @column = column
    @columns = column.board.columns
  end

  def can_move?
    @column.issue_stats.where(archived_at: nil).blank?
  end

  def move_left
    move_to(:left)
  end

  def move_right
    move_to(:right)
  end

  private

  def move_to(direction)
    @columns.each do |column|
      column.order *= 10
      column.order += order_diff(direction) if column.id == @column.id
    end

    @columns.sort_by(&:order).each_with_index do |column, index|
      column.update(order: index + 1)
    end
  end

  def order_diff(direction)
    direction == :left ? -11 : 11
  end
end
