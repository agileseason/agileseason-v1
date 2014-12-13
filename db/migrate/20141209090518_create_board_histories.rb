class CreateBoardHistories < ActiveRecord::Migration
  def change
    create_table :board_histories do |t|
      t.references :board, index: true
      t.date :collected_on
      t.text :data

      t.timestamps
    end
  end
end
