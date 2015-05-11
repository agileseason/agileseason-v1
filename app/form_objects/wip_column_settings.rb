class WipColumnSettings
  include Virtus.model

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attribute :min, Integer
  attribute :max, Integer

  validates :min, numericality: { only_integer: true, allow_nil: true }
  validates :max, numericality: { only_integer: true, allow_nil: true }

  def persisted?
    false
  end

  def save_to(column)
    return false unless valid?
    column.wip_settings = self
    column.save!
  end

  def valid?
    fix_empty_string
    super
  end

  private

  def fix_empty_string
    self.min = nil if min.blank?
    self.max = nil if max.blank?
  end
end
