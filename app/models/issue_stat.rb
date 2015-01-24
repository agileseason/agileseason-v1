class IssueStat < ActiveRecord::Base
  belongs_to :board
  has_many :lifetimes

  validates :number, presence: true
  validates_uniqueness_of :number, scope: :board_id

  serialize :track_data

  scope :closed, -> { where('closed_at is not null') }
  scope :open, -> { where('closed_at is null') }

  def elapsed_time
    (closed_at || Time.current) - created_at
  end

  def elapsed_days
    elapsed_time / 86400
  end
end
