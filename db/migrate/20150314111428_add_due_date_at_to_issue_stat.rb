class AddDueDateAtToIssueStat < ActiveRecord::Migration
  def change
    add_column :issue_stats, :due_date_at, :datetime
  end
end
