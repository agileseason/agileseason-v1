class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :github_username, null: false
      t.string :remember_token

      t.timestamps
    end
  end
end
