class AddFullNameToBoard < ActiveRecord::Migration
  def change
    add_column :boards, :github_full_name, :string, limit: 500
  end
end
