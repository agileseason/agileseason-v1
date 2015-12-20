class AddIsPrivateRepoToBoard < ActiveRecord::Migration
  def change
    add_column :boards, :is_private_repo, :boolean, default: true
  end
end
