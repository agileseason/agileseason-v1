class RepoHistory < ActiveRecord::Base
  belongs_to :board

  validates :board, presence: true
  validates :collected_on, presence: true
end
