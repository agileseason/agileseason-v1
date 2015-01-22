class Boards::ScrumBoard < Board
  def self.model_name
    Board.model_name
  end

  def days_per_iteration
    settings[:days_per_iteration] || 14
  end

  def days_per_iteration=(days)
    settings[:days_per_iteration] = days
  end

  def start_iteration
    settings[:start_iteration] || :monday
  end

  def start_iteration=(week_day)
    settings[:start_iteration] = week_day
  end

  def scrum_settings
    ScrumSettings.new(
      days_per_iteration: days_per_iteration,
      start_iteration: start_iteration
    )
  end
end
