class AddConstrainsToIssueStats < ActiveRecord::Migration
  def change
    add_index :issue_stats, [:number, :board_id], unique: true
  end
end
