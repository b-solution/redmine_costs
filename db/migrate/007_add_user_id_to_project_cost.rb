class AddUserIdToProjectCost < ActiveRecord::Migration
  def change
    add_column :project_costs, :user_id, :integer
    remove_column :project_costs, :role_id

  end
end
