class IssueStat < ActiveRecord::Base
  belongs_to :board

  validates :number, presence: true
  validates_uniqueness_of :number, scope: :board_id

  scope :closed, -> { where('closed_at is not null') }

  def elapsed_time
    (closed_at || Time.current) - created_at
  end

  def elapsed_days
    elapsed_time / 86400
  end
end
