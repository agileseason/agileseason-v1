class AddSettingsToBoard < ActiveRecord::Migration
  def change
    add_column :boards, :settings, :text
  end
end
