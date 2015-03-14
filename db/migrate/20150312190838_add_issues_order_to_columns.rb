class AddIssuesOrderToColumns < ActiveRecord::Migration
  def change
    add_column :columns, :issues_numbers_ordered, :string
  end
end
