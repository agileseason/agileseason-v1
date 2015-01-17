class CreateIssueStats < ActiveRecord::Migration
  def change
    create_table :issue_stats do |t|
      t.references :board, index: true
      t.integer :number
      t.datetime :closed_at

      t.timestamps
    end
  end
end
