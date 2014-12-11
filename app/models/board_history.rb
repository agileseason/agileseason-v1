class BoardHistory < ActiveRecord::Base
  belongs_to :board

  validates :collected_on, presence: true
  serialize :data

  def update_data_issues(board_issues)
    self.data = board.columns.each_with_object([]) do |column, data|
      data << {
        column_id: column.id,
        issues: board_issues[column.label_name].try(:size).to_i
      }
    end
  end
end
