class AddColumnIdToIssueStats < ActiveRecord::Migration
  def up
    add_column :issue_stats, :column_id, :integer
    add_index :issue_stats, [:column_id]

    IssueStat.all.each do |issue_stat|
      if issue_stat.board && !issue_stat.column
        column = issue_stat.closed? ? issue_stat.board.columns.last : issue_stat.board.columns.first
        issue_stat.update(column: column)
      end
    end
  end

  def down
    remove_index :issue_stats, [:column_id]
    remove_column :issue_stats, :column_id
  end
end
