class AddColumnIdToIssueStats < ActiveRecord::Migration
  def up
    add_column :issue_stats, :column_id, :integer
    add_index :issue_stats, [:column_id]

    IssueStat.all.each do |issue_stat|
      issue_stat.update(column: issue_stat.board.columns.first) if issue_stat.board && !issue_stat.column
    end
  end

  def down
    remove_index :issue_stats, [:column_id]
    remove_column :issue_stats, :column_id
  end
end
