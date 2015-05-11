class AddSettingsToColumn < ActiveRecord::Migration
  def change
    add_column :columns, :settings, :text
  end
end
