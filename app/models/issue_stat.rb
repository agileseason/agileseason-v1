class IssueStat < ActiveRecord::Base
  belongs_to :board

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

  def clean_track_data_for(columns_ids)
    columns_ids.each do |column_id|
      if track_data[:columns]
        track_data[:columns].delete(column_id)
      end
    end
    track_data
  end
end
