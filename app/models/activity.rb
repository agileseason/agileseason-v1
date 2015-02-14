class Activity < ActiveRecord::Base
  belongs_to :user
  belongs_to :board
  belongs_to :issue_stat

  serialize :data

  validates :user, presence: true

  def description
  end
end
