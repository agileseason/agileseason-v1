class CreateColumns < ActiveRecord::Migration
  def change
    create_table :columns do |t|
      t.references :board, index: true
      t.string :name
      t.string :color
      t.integer :order

      t.timestamps
    end
  end
end
