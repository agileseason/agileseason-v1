class IssueStat < ActiveRecord::Base
  belongs_to :board

  validates :number, presence: true
end
