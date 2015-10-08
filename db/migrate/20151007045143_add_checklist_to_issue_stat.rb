class AddChecklistToIssueStat < ActiveRecord::Migration
  def change
    add_column :issue_stats, :checklist, :integer, nil: true
    add_column :issue_stats, :checklist_progress, :integer, nil: true
  end
end
