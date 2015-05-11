class Column < ActiveRecord::Base
  belongs_to :board
  has_many :issue_stats, dependent: :destroy
  has_many :lifetimes, dependent: :destroy

  validates :name, presence: true
  validates :board, presence: true

  serialize :issues
  serialize :settings

  def next_columns
    board.columns.select { |c| c.order > order }
  end

  def prev_columns
    board.columns.select { |c| c.order < order }
  end

  def issues
    self['issues'] = [] if self['issues'].nil?
    self['issues']
  end

  def settings
    if super.nil?
      self.settings = {}
    end
    super
  end

  def wip_settings
    WipColumnSettings.new(
      min: settings[:min],
      max: settings[:max]
    )
  end

  def wip_settings=(wip_settings)
    settings[:min] = wip_settings.min
    settings[:max] = wip_settings.max
  end
end
