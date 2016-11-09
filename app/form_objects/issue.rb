class Issue
  include Virtus.model

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attribute :title, String
  attribute :body, String
  attribute :labels, Array[String]
  attribute :color, String
  attribute :column_id, Integer

  validates :title, presence: true

  def persisted?
    false
  end
end
