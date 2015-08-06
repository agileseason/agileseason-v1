class RemoveForeignKeyFromSubscription < ActiveRecord::Migration
  def change
    remove_foreign_key :subscriptions, :boards
  end
end
