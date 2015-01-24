class Board < ActiveRecord::Base
  belongs_to :user
  has_many :columns, -> { order(:order) }
  has_many :repo_histories, -> { order(:collected_on) }
  has_many :board_histories, -> { order(:collected_on) }
  has_many :issue_stats, -> { order(:number) }

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
end
