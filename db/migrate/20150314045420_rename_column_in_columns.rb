class RenameColumnInColumns < ActiveRecord::Migration
  def change
    rename_column :columns, :issues_numbers_ordered, :issues
  end
end
