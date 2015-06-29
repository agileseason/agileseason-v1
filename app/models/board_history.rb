class BoardHistory < ActiveRecord::Base
  belongs_to :board

  validates :collected_on, presence: true, uniqueness: { scope: :board_id }
  validates :data, presence: true

  serialize :data
end
