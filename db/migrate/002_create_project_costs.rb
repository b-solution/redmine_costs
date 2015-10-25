class CreateProjectCosts < ActiveRecord::Migration
  def change
    create_table :project_costs do |t|
      t.integer :project_id
      t.integer :role_id
      t.float :cost
      t.string :unity
    end
  end
end
