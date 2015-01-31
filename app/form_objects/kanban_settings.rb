class KanbanSettings
  include Virtus.model

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attribute :rolling_average_window, Integer
  validates :rolling_average_window, numericality: { only_integer: true }

  def persisted?
    false
  end

  def save_to(board)
    return false unless valid?
    board.rolling_average_window = rolling_average_window
    board.save
  end
end
