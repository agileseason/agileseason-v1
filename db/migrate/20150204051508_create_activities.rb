class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.references :user, index: true
      t.references :board, index: true
      t.references :issue_stat, index: true
      t.string :type
      t.text :data

      t.timestamps null: false
    end
    add_foreign_key :activities, :users, on_delete: :cascade
    add_foreign_key :activities, :boards, on_delete: :cascade
    add_foreign_key :activities, :issue_stats, on_delete: :cascade
  end
end
