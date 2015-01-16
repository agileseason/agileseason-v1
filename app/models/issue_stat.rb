class IssueStat < ActiveRecord::Base
  belongs_to :board

  validates :number, presence: true
  validates_uniqueness_of :number, scope: :board_id
end
