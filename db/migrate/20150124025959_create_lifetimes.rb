class CreateLifetimes < ActiveRecord::Migration
  def change
    create_table :lifetimes do |t|
      t.references :issue_stat, index: true
      t.references :column, index: true
      t.datetime :in_at
      t.datetime :out_at

      t.timestamps null: false
    end
    add_foreign_key :lifetimes, :issue_stats
    add_foreign_key :lifetimes, :columns
  end
end
