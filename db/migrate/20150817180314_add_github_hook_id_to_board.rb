class AddGithubHookIdToBoard < ActiveRecord::Migration
  def change
    add_column :boards, :github_hook_id, :string
  end
end
