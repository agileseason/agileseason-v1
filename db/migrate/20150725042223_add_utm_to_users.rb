class AddUtmToUsers < ActiveRecord::Migration
  def up
    add_column :users, :utm, :json
    User.where(utm: nil).update_all(utm: { source: 'direct' })
  end

  def down
    remove_column :users, :utm
  end
end
