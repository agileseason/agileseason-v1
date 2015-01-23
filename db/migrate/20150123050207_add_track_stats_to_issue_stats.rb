class AddTrackStatsToIssueStats < ActiveRecord::Migration
  def change
    add_column :issue_stats, :track_data, :text
  end
end
