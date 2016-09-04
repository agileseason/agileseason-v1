class AddColorToIssueStat < ActiveRecord::Migration
  def change
    add_column :issue_stats, :color, :string
  end
end
