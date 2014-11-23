class Issue
  include Virtus.model

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attribute :title, String
  attribute :body, String

  validates :title, presence: true
  validates :body, presence: true

  def persisted?
    false
  end
end
