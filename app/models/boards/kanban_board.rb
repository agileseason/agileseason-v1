class Boards::KanbanBoard < Board
  def self.model_name
    Board.model_name
  end

  def kanban_settings
    KanbanSettings.new
  end
end
