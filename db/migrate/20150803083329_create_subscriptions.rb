class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.references :user, index: true, foreign_key: true
      t.references :board, index: true, foreign_key: true
      t.datetime :date_to
      t.decimal :cost

      t.timestamps null: false
    end
  end
end
