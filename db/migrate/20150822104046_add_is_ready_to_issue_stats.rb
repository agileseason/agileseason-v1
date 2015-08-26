class AddIsReadyToIssueStats < ActiveRecord::Migration
  def change
    add_column :issue_stats, :is_ready, :boolean, default: false
  end
end
