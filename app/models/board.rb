class Board < ActiveRecord::Base
  belongs_to :user
  has_many :columns

  validates :name, presence: true
  validates :type, presence: true
  validates :columns, presence: true

  def github_labels
    columns.map(&:label_name)
  end
end
