class IssueStat < ActiveRecord::Base
  belongs_to :board, touch: true
  belongs_to :column
  has_many :lifetimes, dependent: :destroy

  scope :visible, -> { where(archived_at: nil) }

  validates :number, presence: true, uniqueness: { scope: :board_id }

  serialize :track_data

  scope :open, -> { where('closed_at is null') }
  scope :closed, -> { where('closed_at is not null') }
  scope :archived, -> { where('archived_at is not null') }

  def elapsed_time
    (closed_at || Time.current) - created_at
  end

  def elapsed_days
    elapsed_time / 86400
  end

  def closed?
    closed_at.present?
  end

  def archived?
    archived_at.present?
  end
end
