class AddAutoAssignToColumn < ActiveRecord::Migration
  def change
    add_column :columns, :is_auto_assign, :boolean
  end
end
