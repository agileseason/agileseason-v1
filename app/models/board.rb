class Board < ActiveRecord::Base
  belongs_to :user
  has_many :columns, -> { order(:order) }, dependent: :destroy
  has_many :repo_histories, -> { order(:collected_on) }, dependent: :delete_all
  has_many :board_histories, -> { order(:collected_on) }, dependent: :delete_all
  has_many :issue_stats, dependent: :destroy
  has_many :visible_issue_stats, -> { visible }, class_name: IssueStat
  has_many :activities, -> { order(created_at: :desc) }, dependent: :delete_all
  has_many :subscriptions

  validates :name, presence: true
  validates :type, presence: true
  validates :columns, presence: true, length: { minimum: 2 }
  validates :github_name, presence: true
  validates :github_full_name, presence: true

  serialize :settings

  def to_param
    github_full_name
  end

  def github_url
    "https://github.com/#{github_full_name}"
  end

  def kanban?
    type == 'Boards::KanbanBoard'
  end

  def scrum?
    type == 'Boards::ScrumBoard'
  end

  def default_column
    columns.first
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
    is_public
  end

  def danger_settings
    DangerSettings.new(
      is_public: public?
    )
  end
end
