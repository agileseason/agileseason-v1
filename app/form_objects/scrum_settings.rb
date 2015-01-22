class ScrumSettings
  include Virtus.model

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attribute :days_per_iteration, Integer
  attribute :start_iteration, String

  validates :days_per_iteration, numericality: { only_integer: true }
  validates :start_iteration, presence: true

  START_ITERATION_DAYS = [:sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday]

  def persisted?
    false
  end

  def valid?
    unless START_ITERATION_DAYS.include?(start_iteration)
      self[:start_iteration] = START_ITERATION_DAYS.first
    end
    super
  end

  def save_to(board)
    return false unless valid?
    board.days_per_iteration = days_per_iteration
    board.start_iteration = start_iteration
    board.save
  end
end
