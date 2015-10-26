class AddHeritCostToProject < ActiveRecord::Migration
  def change
    add_column :projects, :herit_cost, :boolean, default: false
    # add_column :projects, :unity, :string, default: 'EUR'
  end
end
