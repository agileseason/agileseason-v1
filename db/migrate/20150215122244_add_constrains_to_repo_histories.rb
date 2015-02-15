class AddConstrainsToRepoHistories < ActiveRecord::Migration
  def change
    add_index :repo_histories, [:collected_on, :board_id], unique: true
  end
end
