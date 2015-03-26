class DangerSettings
  include Virtus.model

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attribute :is_public, Boolean

  def persisted?
    false
  end

  def save_to(board)
    return false unless valid?
    board.public = is_public
    board.save
  end
end
