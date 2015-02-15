class RepoHistory < ActiveRecord::Base
  belongs_to :board

  validates :board, presence: true
  validates :collected_on, presence: true
  validates_uniqueness_of :collected_on, scope: :board_id
end
