class AddGithubNameToBoard < ActiveRecord::Migration
  def self.up
    add_column :boards, :github_name, :string

    Board.where(id: 1).update_all(github_name: 'agileseason')
    Board.where('id != 1').update_all('github_name = name')
  end

  def self.down
    remove_column :boards, :github_name
  end
end
