class CreateBoards < ActiveRecord::Migration
  def change
    create_table :boards do |t|
      t.references :user, index: true
      t.string :name
      t.string :type
      t.integer :github_id

      t.timestamps
    end
  end
end
