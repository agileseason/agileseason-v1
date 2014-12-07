class CreateRepoHistories < ActiveRecord::Migration
  def change
    create_table :repo_histories do |t|
      t.references :board, index: true
      t.date :collected_on
      t.integer :lines

      t.timestamps
    end
  end
end
