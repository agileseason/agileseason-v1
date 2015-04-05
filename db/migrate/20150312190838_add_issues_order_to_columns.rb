class AddIssuesOrderToColumns < ActiveRecord::Migration
  def change
    add_column :columns, :issues, :text
  end
end
