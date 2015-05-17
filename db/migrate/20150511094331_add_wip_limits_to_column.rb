class AddWipLimitsToColumn < ActiveRecord::Migration
  def change
    add_column :columns, :wip_min, :integer, null: true
    add_column :columns, :wip_max, :integer, null: true
  end
end
