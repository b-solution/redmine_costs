class AddRoleIdToCostEntry < ActiveRecord::Migration
  def change
    add_column :cost_entries, :role_id, :integer

    CostEntry.all.each do |ce|
      ce.role_id = ce.set_role
      ce.save
    end
  end
end
