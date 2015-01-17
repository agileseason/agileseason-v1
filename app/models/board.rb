class Board < ActiveRecord::Base
  belongs_to :user
  has_many :columns, -> { order(:order) }
  has_many :repo_histories, -> { order(:collected_on) }
  has_many :board_histories, -> { order(:collected_on) }
  has_many :issue_stats, -> { order(:number) }

  validates :name, presence: true
  validates :type, presence: true
  validates :columns, presence: true

  def github_labels
    columns.map(&:label_name)
  end

  def to_param
    github_name
  end
end
