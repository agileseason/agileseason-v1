class Board < ActiveRecord::Base
  belongs_to :user
  has_many :columns, -> { order(:order) }, dependent: :destroy
  has_many :repo_histories, -> { order(:collected_on) }, dependent: :delete_all
  has_many :board_histories, -> { order(:collected_on) }, dependent: :delete_all
  has_many :issue_stats, dependent: :destroy
  has_many :activities, -> { order(created_at: :desc) }, dependent: :delete_all

  validates :name, presence: true
  validates :type, presence: true
  validates :columns, presence: true

  serialize :settings

  def column_labels
    @column_labels ||= columns.map(&:label_name)
  end
  alias :github_labels :column_labels

  def to_param
    github_name
  end

  def kanban?
    type == 'Boards::KanbanBoard'
  end

  def scrum?
    type == 'Boards::ScrumBoard'
  end

  def settings
    if super.nil?
      self.settings = {}
    end
    super
  end

  def find_stat(issue)
    issue_stats.find_by(number: issue.number)
  end

  def public?
    settings[:is_public]
  end

  def public=(value)
    settings[:is_public] = value
  end

  def danger_settings
    DangerSettings.new(
      is_public: public?
    )
  end
end
