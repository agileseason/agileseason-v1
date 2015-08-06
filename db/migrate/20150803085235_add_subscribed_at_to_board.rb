class AddSubscribedAtToBoard < ActiveRecord::Migration
  def change
    add_column :boards, :subscribed_at, :datetime
  end
end
