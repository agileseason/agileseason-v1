class KanbanSettings
  include Virtus.model

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  # NOTE Now no fields

  def persisted?
    false
  end

  def save_to(board)
    return false unless valid?
    board.save
  end
end
