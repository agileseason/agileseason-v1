class IssueStat < ActiveRecord::Base
  belongs_to :board
  belongs_to :column
  has_many :lifetimes, dependent: :destroy

  validates :number, presence: true, uniqueness: { scope: :board_id }

  serialize :track_data

  scope :archived, -> { where.not(archived_at: nil) }
  scope :closed, -> { where.not(closed_at: nil) }
  scope :open, -> { where(closed_at: nil) }
  scope :visible, -> { where(archived_at: nil) }

  def elapsed_time
    (closed_at || Time.current) - created_at
  end

  def elapsed_days
    elapsed_time / 86400
  end

  def closed?
    closed_at.present?
  end

  def archive?
    archived_at.present?
  end

  alias :archived? :archive?

  def state
    closed? ? :closed : :open
  end
end
