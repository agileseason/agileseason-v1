class BoardHistory < ActiveRecord::Base
  belongs_to :board

  validates :collected_on, presence: true
  serialize :data

  def update_data_issues(board_issues)
    issues_group = board_issues.each_with_object({}) { |pair, mem| mem[pair[0]] = pair[1].try(:size).to_i }
    total_issues = issues_group.sum { |e| e[1] }
    self.data = board.columns.each_with_object([]) do |column, data|
      count = issues_group[column.label_name]
      data << {
        column_id: column.id,
        issues: count,
        issues_cumulative: total_issues
      }
      total_issues -= count
    end
  end
end
