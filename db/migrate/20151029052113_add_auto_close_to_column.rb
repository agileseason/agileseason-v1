class AddAutoCloseToColumn < ActiveRecord::Migration
  def change
    add_column :columns, :is_auto_close, :boolean
  end
end
