class AddConstrainsToBoardHistories < ActiveRecord::Migration
  def change
    add_index :board_histories, [:collected_on, :board_id], unique: true
  end
end
