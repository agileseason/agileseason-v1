class Activity < ActiveRecord::Base
  belongs_to :user
  belongs_to :board
  belongs_to :issue_stat

  serialize :data

  def description
  end
end
