module PreferenceHelper
  # Kanban user preferences
  DEFAULT_ROLLING_AVERAGE_WINDOW = 6

  def rolling_average_window
    days = get(:rolling_average_window).to_i
    days > 0 ? days : DEFAULT_ROLLING_AVERAGE_WINDOW
  end

  def rolling_average_window=(days)
    days = days.to_i if days.is_a?(String)
    set(:rolling_average_window, days) if days > 0
  end

  private

  def set(key, value)
    cookies[key] = { value: value, expires: 6.months.from_now }
  end

  def get(key)
    cookies[key]
  end
end
