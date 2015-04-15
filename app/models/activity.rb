class Activity < ActiveRecord::Base
  belongs_to :user
  belongs_to :board
  belongs_to :issue_stat

  serialize :data

  validates :user, presence: true

  self.per_page = 20

  def description
  end
end
