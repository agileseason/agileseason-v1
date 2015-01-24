class AddArchivedAtToIssueStats < ActiveRecord::Migration
  def change
    add_column :issue_stats, :archived_at, :datetime
  end
end
