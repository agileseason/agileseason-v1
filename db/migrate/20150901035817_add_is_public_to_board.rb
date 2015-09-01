class AddIsPublicToBoard < ActiveRecord::Migration
  def up
    add_column :boards, :is_public, :boolean, default: false
    Board.all.each do |board|
      board.update(is_public: true) if board.settings[:is_public] == true
    end
  end

  def down
    remove_column :boards, :is_public
  end
end
