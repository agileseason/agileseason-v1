class Boards::KanbanBoard < Board
  DEFAULT_ROLLING_AVERAGE_WINDOW = 6

  def self.model_name
    Board.model_name
  end

  def rolling_average_window
    settings[:rolling_average_window] || DEFAULT_ROLLING_AVERAGE_WINDOW
  end

  def rolling_average_window=(days)
    settings[:rolling_average_window] = days
  end

  def kanban_settings
    KanbanSettings.new(
      rolling_average_window: rolling_average_window
    )
  end
end
