class AddColumnIdToIssueStats < ActiveRecord::Migration
  def change
    add_column :issue_stats, :column_id, :integer
    add_index :issue_stats, [:column_id]
  end
end
